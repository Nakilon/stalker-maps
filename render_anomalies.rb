require_relative "render"

db = Dir.glob("out/config/misc/zone_*.ltx").flat_map{ |f| File.read(f, encoding: "CP1251").encode("utf-8", "cp1251").scan(/(?<=^\[)[^\]]+/).map{ |_| [_, f[/(?<=_)[^.]+/]] } }.to_h

objs = ALL.select do |obj|
  db.key? obj["section_name"]
end.compact
puts "ANOMALIES: #{objs.size}"
abort if objs.size < 150

image = Image.new Vips::Image.new_from_file ARGV[1]

short = {
  # "mosquitobald" => "M",
  "minefield" => "F",
  "radioactive" => "R",
  "witchesgalantine" => "W",
}

# data
names = objs.map do |obj|
  x, _, y = obj["position"]
  name = db[obj["section_name"]]
  if "mosquitobald" == name
    image.image = image.image.draw_circle [192, 192, 192], fx(x), fy(y), 2, fill: true
    next
  end
  name = short.fetch name, name
  [name, *image.marker(fx(x), fy(y), name, 80)]
end.compact

# legend
strings = File.read("out/config/text/eng/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, 50, strings.fetch(ARGV[2]), 250)).flatten
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, image.image.height - 50, "nakilon@gmail.com")).flatten
x = y = 50
require "mll"
image.image = image.image.draw_circle [192, 192, 192], x, y, 2, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y, "mosquitobald", 80)).flatten
short.each do |long, short|
  y += 14
  image.image = image.image.composite2(*image.prepare_text(x - 10, y, "#{short}  #{long}", 80)).flatten
end

begin
  moved = 0
  names.permutation(2) do |name1, name2|
    n1, t1, _, xy1 = *name1
    n2, t2, _, xy2 = *name2
    next if n1.size == 1 || n2.size == 1
    next unless (xy1[:y] + t1.height > xy2[:y]) &&
                (xy1[:y]             < xy2[:y]) &&
                (xy1[:x] + t1.width  > xy2[:x]) &&
                (xy1[:x] < t2.width  + xy2[:x])
    moved += 1
    name1[3][:y] -= 1
    name2[3][:y] += 1
  end
  puts "#{moved} texts moved"
end until moved.zero?

names.each{ |_, *name| image.image = image.image.composite2(*name).flatten }

image.image.write_to_file "rendered/#{ARGV[2]}_anomalies.png"

puts "OK"
