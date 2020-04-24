require "pp"

require "yaml"
all = YAML.load_file ARGV[0]
p all.size

require "vips"
image = Vips::Image.new_from_file ARGV[1]
fx = ->x{ 419 + x * 1.28 }
fy = ->y{ 990 - y * 1.3725 }
all.map! do |item|
  next unless "stalker" == item["section_name"]
  next if "esc_provodnik" == item["name"]
  if t = item["custom_data"].to_h["spawner"]
    fail if t.grep(/\Acond = \{\+/).empty?
    next unless [["cond = {+tutorial_wounded_start}"], ["cond = {+escape_stalker_help}"]].include? t
  end
  health = item["health"] || item["upd:health"]
  fail item["id"].to_s unless health
  color, draw_name =
     if health <= 0 ; [[255, 0,   0]]
  elsif health < 1  ; [[255, 255, 0], true]
  elsif health > 1  ; [[0,   255, 0], (item["name"] != "esc_novice_attacker3")]
  else              ; [[255, 255, 255]]
  end
  x, _, y = item["position"]
  image = image.draw_circle color, fx[x], fy[y], 2, fill: true
  if draw_name
    text = Vips::Image.text item["character_name"], width: image.width - fx[x] - 5, dpi: 100, font: "Verdana Bold"
    image = image.composite2(text.new_from_image([192, 192, 192]).copy(interpretation: :srgb).bandjoin(text), :over, x: fx[x] + 5, y: fy[y] - 6).flatten
  end
  [item["position"].map{ |_| _.round 2 }, item["health"], item["upd:health"], item["character_name"]]
end

image.write_to_file ARGV[2]

