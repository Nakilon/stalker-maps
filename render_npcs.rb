require_relative "render"

npcs = ALL.select do |item|
  next unless %w{ stalker stalker_trader }.include? item["section_name"]
  next if 1 == item["community_index"] # actor_dolg
  next if 14 == item["community_index"] # arena_enemy
  if t = item["custom_data"].to_h["spawner"]
    next true unless t.grep(/\Acond = \{-/).empty?
    fail item.inspect if t.grep(/\Acond = \{+/).empty?
    next if [["cond = {+bar_arena_fight_8}"]].include? t
  end
  true
end.compact
puts "NPC: #{npcs.size}"
abort "< #{Fixtures.fetch(ARGV[1])[:NPCS]}" if npcs.size < Fixtures.fetch(ARGV[1])[:NPCS]

image = Render.prepare_image "rus"
colors = [p,p,p,[192,192,192],p,[0,150,0],[0,0,192],[192,192,0],[192,0,0],[192,128,0],[192,128,128]]
# communities   = actor, 0, actor_dolg, 1, actor_freedom, 2, stalker, 5, monolith, 6, military, 7, killer, 8, ecolog, 9, dolg, 10, freedom, 11, bandit, 12, zombied, 13, stranger, 14, trader, 15, arena_enemy, 16

names_other = ARGV.drop(2).map do |file|
  YAML.load_file(file).map{ |item| item["character_name"] }
end
# data
names = npcs.map do |npc|
  health = npc["health"] || npc["upd:health"]
  fail npc["id"].to_s unless health
  fail npc["community_index"].to_s unless color = colors[npc["community_index"]]
  x, _, y = npc["position"]
  draw_name = !!npc["story_id"]
  if health == 0
    image.image = image.image.draw_line color, fx(x) - 3, fy(y) - 3, fx(x) + 3, fy(y) + 3
    image.image = image.image.draw_line color, fx(x) - 3, fy(y) + 3, fx(x) + 3, fy(y) - 3
  elsif health < 0.5
    image.image = image.image.draw_circle color, fx(x), fy(y), 3
    draw_name = true
  elsif health < 2
    image.image = image.image.draw_circle color, fx(x), fy(y), 3, fill: true
  elsif health == 2
    image.image = image.image.draw_circle color, fx(x), fy(y), 3, fill: true
    draw_name = true
  else ; fail
  end
  # TODO: also render names that are just common for all saves, no matter if they have quest or not
  image.prepare_text(fx(x), fy(y), names_other.all?{ |other|
    other.include?(npc["character_name"])
  } ? npc["character_name"] : npc["name"], 80) if draw_name && npc["name"] != "esc_novice_attacker3"
end.compact
begin
  moved = false
  names.permutation(2) do |name1, name2|
    t1, _, xy1 = *name1
    t2, _, xy2 = *name2
    next unless (xy1[:y] + t1.height > xy2[:y]) &&
                (xy2[:y] + t2.height > xy1[:y]) &&
                (xy1[:x] + t1.width  > xy2[:x]) &&
                (xy2[:x] + t2.width  > xy1[:x])
    moved = true
    if xy1[:y] + t1.height / 2.0 > xy2[:y] + t2.height / 2.0
      name1[2][:y] += 1
      name2[2][:y] -= 1
    elsif xy1[:y] + t1.height / 2.0 < xy2[:y] + t2.height / 2.0
      name1[2][:y] -= 1
      name2[2][:y] += 1
    elsif xy1[:x] < xy2[:x]
      name1[2][:y] += 1
      name2[2][:y] -= 1
    else
      name1[2][:y] -= 1
      name2[2][:y] += 1
    end
  end
end while moved
names.each{ |name| image.image = image.image.composite2(*name).flatten }

# legend
communities = File.read("out/config/creatures/game_relations.ltx", encoding: "CP1251").encode("utf-8", "cp1251")[/^communities\s*=\s*(.+)/, 1].split(?,).each_slice(2).map(&:first).map &:strip
strings = File.read("out/config/text/rus/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
x, y = 50, 38
colors.each_with_index do |color, index|
  next unless npcs.any?{ |npc| index == npc["community_index"] }
  y += 15
  image.image = image.image.draw_circle color, x, y, 3, fill: true
  image.image = image.image.composite2(*image.prepare_text(x + 10, y, strings.fetch(communities[index]), 80)).flatten
end
y += 25
image.image = image.image.draw_circle [192,192,192], x, y, 3, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y + 2, "жив", 80)).flatten
y += 15
image.image = image.image.draw_circle [192,192,192], x, y, 3
image.image = image.image.composite2(*image.prepare_text(x + 10, y + 2, "ранен", 80)).flatten
y += 15
image.image = image.image.draw_line [192,192,192], x - 3, y - 3, x + 3, y + 3
image.image = image.image.draw_line [192,192,192], x - 3, y + 3, x + 3, y - 3
image.image = image.image.composite2(*image.prepare_text(x + 10, y + 2, "мертв", 80)).flatten

image.image.write_to_file "rendered/#{ARGV[1]}_npcs.jpg", Q: 95


puts "OK"

