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
  health = npc["health"] || npc["upd:health"]
  fail npc["id"].to_s unless health
  fail unless color = [p,p,p,[255,255,255],p,[0,150,0],p,p,p,p,[255,0,0]][npc["community_index"]]
  x, _, y = npc["position"]
  draw_name = !!npc["story_id"]
  if health == 0
    image = image.draw_line color, fx[x] - 3, fy[y] - 3, fx[x] + 3, fy[y] + 3
    image = image.draw_line color, fx[x] - 3, fy[y] + 3, fx[x] + 3, fy[y] - 3
  elsif health < 0.5
    image = image.draw_circle color, fx[x], fy[y], 3
    draw_name = true
  elsif health < 2
    image = image.draw_circle color, fx[x], fy[y], 3, fill: true
  elsif health == 2
    image = image.draw_circle color, fx[x], fy[y], 3, fill: true
    draw_name = true
  else ; fail
  end
  if draw_name && npc["name"] != "esc_novice_attacker3"
    text = Vips::Image.text (
      %w{ esc_tutorial_dead_novice esc_factory_prisoner_guard }.include?(npc["name"]) ? npc["name"] : npc["character_name"]
    ), width: image.width - fx[x] - 6, dpi: 100, font: "Verdana Bold"
    image = image.composite2(text.new_from_image([192, 192, 192]).copy(interpretation: :srgb).bandjoin(text), :over, x: fx[x] + 6, y: fy[y] - 6).flatten
  end
end
image.write_to_file "rendered/#{ARGV[2]}_npcs.png"


puts "OK"

