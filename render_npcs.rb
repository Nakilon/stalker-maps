require_relative "render"

npcs = ALL.select do |item|
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

image = Render.prepare_image

# legend
colors = [p,p,p,[192,192,192],p,[0,150,0],p,p,[192,0,0],p,[192,192,255]]
communities = File.read("out/config/creatures/game_relations.ltx", encoding: "CP1251").encode("utf-8", "cp1251")[/^communities\s*=\s*(.+)/, 1].split(?,).each_slice(2).map(&:first).map &:strip
strings = File.read("out/config/text/rus/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, 50, strings.fetch(ARGV[1]), 250)).flatten
image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, image.image.height - 50, "nakilon@gmail.com")).flatten
x = y = 50
image.image = image.image.draw_circle colors[3], x, y, 3, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y, strings.fetch(communities[3]), 80)).flatten
y += 12
image.image = image.image.draw_circle colors[5], x, y, 3, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y, strings.fetch(communities[5]), 80)).flatten
y += 12
image.image = image.image.draw_circle colors[10], x, y, 3, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y, strings.fetch(communities[10]), 80)).flatten
y += 24
image.image = image.image.draw_circle [192,192,192], x, y, 3, fill: true
image.image = image.image.composite2(*image.prepare_text(x + 10, y, "жив")).flatten
y += 12
image.image = image.image.draw_circle [192,192,192], x, y, 3
image.image = image.image.composite2(*image.prepare_text(x + 10, y, "ранен")).flatten
y += 12
image.image = image.image.draw_line [192,192,192], x - 3, y - 3, x + 3, y + 3
image.image = image.image.draw_line [192,192,192], x - 3, y + 3, x + 3, y - 3
image.image = image.image.composite2(*image.prepare_text(x + 10, y, "мертв")).flatten

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
  image.prepare_text(fx(x), fy(y), %w{ esc_tutorial_dead_novice esc_factory_prisoner_guard }.include?(npc["name"]) ? npc["name"] : npc["character_name"], 80) if draw_name && npc["name"] != "esc_novice_attacker3"
end.compact
begin
  moved = false
  names.permutation(2) do |name1, name2|
    t1, _, xy1 = *name1
    t2, _, xy2 = *name2
    next unless (xy1[:y]...xy1[:y]+t1.height).include?(xy2[:y]) && (
                (xy1[:x]...xy1[:x]+t1.width ).include?(xy2[:x]) ||
                (xy1[:x]...xy1[:x]+t1.width).include?(xy2[:x]+t2.width))
    moved = true
    name1[2][:y] -= 1
    name2[2][:y] += 1
  end
end while moved
names.each{ |name| image.image = image.image.composite2(*name).flatten }

image.image.write_to_file "rendered/#{ARGV[1]}_npcs.jpg", Q: 95


puts "OK"

