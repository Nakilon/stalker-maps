require_relative "render"

mutants = ALL.select do |item|
  next unless /\Amonsters\\/ =~ item["visual_name"]
  true
end.compact
puts "MUTANTS: #{mutants.size}"
abort if mutants.size < 100

image = Image.new Vips::Image.new_from_file ARGV[1]

# data
names = mutants.map do |obj|
  health = obj["health"] || obj["upd:health"]
  fail obj["id"].to_s unless health
  fail if obj["community_index"]
  x, _, y = obj["position"]
  fail if obj["character_name"]
  name = obj["visual_name"].split("\\")[1]
  name = "boar" if name == "mutant_boar"
  name = "!#{name}!" if obj["story_id"]
  [name, *image.marker(fx(x), fy(y), name, 80)] #if obj["story_id"]
end.compact

# legend
strings = File.read("out/config/text/eng/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, 50, strings.fetch(ARGV[2]), 250)).flatten
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, image.image.height - 50, "nakilon@gmail.com")).flatten
x = y = 50
require "mll"
image.image = image.image.composite2(*image.prepare_text(x + 10, y, "Total:", 160)).flatten
y += 18
MLL::tally[(names.map(&:first) - %w{!flesh!})].sort_by(&:last).reverse.each do |m, c|
  y += 12
  image.image = image.image.composite2(*image.prepare_text(x + 10, y, "#{c}x #{m}", 80)).flatten
end

groups = []
group = []
queue = []
until names.empty?
  queue.push names.shift
  until queue.empty?
    group.push current = queue.shift
    n1, t1, _, xy1 = *current
    a, b = names.partition do |n2, t2, _, xy2|
      n1 == n2 && (xy1[:y] + t1.width > xy2[:y]) &&
                  (xy1[:y] < t2.width + xy2[:y]) &&
                  (xy1[:x] + t1.width > xy2[:x]) &&
                  (xy1[:x] < t2.width + xy2[:x])
    end
    queue.concat a
    names.replace b
  end
  groups.push group
  group = []
end
names = groups.map do |group|
  next group.first.drop 1 if group.size == 1
  # TODO: maybe somehow do not init Vips object until here
  x = group.map(&:last).sum{ |_| _[:x] } / group.size
  y = group.map(&:last).sum{ |_| _[:y] } / group.size
  text, mode, xy = *image.marker(0, 0, "#{group.size}x #{group.first.first}#{?e if "flesh" == group.first.first}s", 80)
  [text, mode, x: x, y: y]
end
puts "#{groups.sum &:size} => #{names.size}"

begin
  moved = 0
  names.permutation(2) do |name1, name2|
    t1, _, xy1 = *name1
    t2, _, xy2 = *name2
    next unless (xy1[:y]...xy1[:y]+t1.height).include?(xy2[:y]) && (
                (xy1[:x]...xy1[:x]+t1.width ).include?(xy2[:x]) ||
                (xy1[:x]...xy1[:x]+t1.width).include?(xy2[:x]+t2.width))
    moved += 1
    name1[2][:y] -= 1
    name2[2][:y] += 1
  end
  # puts "#{moved} texts moved"
end until moved.zero?
names.each{ |name| image.image = image.image.composite2(*name).flatten }

image.image.write_to_file "rendered/#{ARGV[2]}_mutants.png"

puts "OK"
