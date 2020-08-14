require_relative "render"

db = Dir.glob("out/config/misc/zone_*.ltx").flat_map{ |f| File.read(f, encoding: "CP1251").encode("utf-8", "cp1251").scan(/(?<=^\[)[^\]]+/).map{ |_| [_, f[/(?<=_)[^.]+/]] } }.to_h

objs = ALL.select do |obj|
  db.key? obj["section_name"]
end.compact
puts "ANOMALIES: #{objs.size}"
abort "< #{Fixtures.fetch(ARGV[1])[:ANOMALIES]}" if objs.size < Fixtures.fetch(ARGV[1])[:ANOMALIES]


image = Render.prepare_image "eng"

short = {
  "mincer" => "M",
  "minefield" => "ſ",
  "radioactive" => "☢",
  "witchesgalantine" => "ϟ",
  "gravi" => "G",
  "zharka_static" => "🔥",
  "burningfuzz" => "ዣ",
  "teleport" => "0",
}

# data
was_moskito = false
names = objs.map do |obj|
  x, _, y = obj["position"]
  name = db[obj["section_name"]]
  if "mosquitobald" == name
    was_moskito = true
    image.image = image.image.draw_circle [192, 192, 192], fx(x), fy(y), 2, fill: true
    next
  end
  name = short.fetch name, name
  [name, *image.marker(fx(x), fy(y), name)]
end.compact

# legend
strings = File.read("out/config/text/eng/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
x = y = 50
if was_moskito
  image.image = image.image.draw_circle [192, 192, 192], x, y, 2, fill: true
  # TODO: maybe use some Unicode dot?
  image.image = image.image.composite2(*image.prepare_text(x + 10, y, "mosquitobald")).flatten
  y += 20
end
short.each do |long, short|
  next unless names.assoc short
  image.image = image.image.composite2(*image.prepare_text(x - 10, y, "#{short}  #{long}")).flatten
  y += 20
end

begin
  moved = 0
  names.permutation(2) do |name1, name2|
    n1, t1, _, xy1 = *name1
    n2, t2, _, xy2 = *name2
    next if n1.size == 1 || n2.size == 1
    next unless (xy1[:y] + t1.height > xy2[:y]) &&
                (xy2[:y] + t2.height > xy1[:y]) &&
                (xy1[:x] + t1.width  > xy2[:x]) &&
                (xy2[:x] + t2.width  > xy1[:x])
    moved += 1
    if xy1[:y] + t1.height / 2.0 > xy2[:y] + t2.height / 2.0
      name1[3][:y] += 1
      name2[3][:y] -= 1
    else
      name1[3][:y] -= 1
      name2[3][:y] += 1
    end
  end
  puts "#{moved} texts moved"
end until moved.zero?

texts, xs, ys = names.map{ |_, text, _, xy| [text, xy[:x], xy[:y]] }.transpose
image.image = image.image.composite texts, :over, x: xs, y: ys if texts

image.image.write_to_file "rendered/#{ARGV[1]}_anomalies.jpg", Q: 95


puts "OK"
