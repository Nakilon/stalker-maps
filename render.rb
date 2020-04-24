require "pp"

require "yaml"
all = YAML.load_file ARGV[0]
puts "ALL: #{all.size}"
abort if all.size < 1000

npcs = all.select do |item|
  next unless "stalker" == item["section_name"]
  next if "esc_provodnik" == item["name"]
  if t = item["custom_data"].to_h["spawner"]
    fail if t.grep(/\Acond = \{\+/).empty?
    next unless [["cond = {+tutorial_wounded_start}"], ["cond = {+escape_stalker_help}"]].include? t
  end
  true
end.compact
puts "NPC: #{npcs.size}"
abort if npcs.size < 50
fx = ->x{ 419 + x * 1.28 }
fy = ->y{ 990 - y * 1.3725 }
require "vips"

image = Vips::Image.new_from_file ARGV[1]
communities = File.read("out/config/creatures/game_relations.ltx", encoding: "CP1251").encode("utf-8", "cp1251")[/^communities\s*=\s*(.+)/, 1].split(?,).each_slice(2).map(&:first).map &:strip
npcs.each do |npc|
  color = [p,p,p,[255,255,255],p,[0,150,0],p,p,p,p,[255,0,0]][npc["community_index"]]
  x, _, y = npc["position"]
  image = image.draw_circle color, fx[x], fy[y], 2, fill: true
end
image.write_to_file "rendered/#{ARGV[2]}_communities.png"

image = Vips::Image.new_from_file ARGV[1]
npcs.map do |npc|
  health = npc["health"] || npc["upd:health"]
  fail npc["id"].to_s unless health
  color, draw_name =
     if health <= 0 ; [[255, 96,  0]]
  elsif health < 1  ; [[255, 255, 0], true]
  elsif health > 1  ; [[0,   255, 0], (npc["name"] != "esc_novice_attacker3")]
  else              ; [[255, 255, 255]]
  end
  x, _, y = npc["position"]
  image = image.draw_circle color, fx[x], fy[y], 2, fill: true
  if draw_name
    text = Vips::Image.text npc["character_name"], width: image.width - fx[x] - 5, dpi: 100, font: "Verdana Bold"
    image = image.composite2(text.new_from_image([192, 192, 192]).copy(interpretation: :srgb).bandjoin(text), :over, x: fx[x] + 5, y: fy[y] - 6).flatten
  end
end
image.write_to_file "rendered/#{ARGV[2]}_health.png"


puts "OK"

