require_relative "render"

not_localized, *rest = [ALL, *ARGV[2,5].map(&YAML.method(:load_file))].map do |_|
  _.reject do |obj|
    not ARGV.drop(12).include? obj["section_name"] or obj.key? "parent_id"
  # next (fail if obj.to_s["af_"]) if treasures.include? obj["story_id"]
  # next true unless obj.to_s["af_"]
  # next if obj["section_name"][/\Aaf_/]
  # (pp obj; fail) unless obj["custom_data"].is_a? Array
  # case obj["custom_data"].size
  # when 1
  #   (pp obj; fail) unless obj["custom_data"][0].size == 2
  #   (pp obj; fail) unless obj["custom_data"][0][0] == "drop_box"
  #   (pp obj; fail) unless obj["custom_data"][0][1].is_a? Array
  #   (pp obj; fail) unless obj["custom_data"][0][1].size == 2
  #   (pp obj; fail) unless obj["custom_data"][0][1][0][/\Acommunity = \S+_box\S*\z/]
  #   (pp obj; fail) unless obj["custom_data"][0][1][1][/\Aitems = af_[a-z_]+\z/]
  # when 2
  #   (pp obj; fail) unless obj["custom_data"][0] == ["dont_spawn_character_supplies", []]
  #   (pp obj; fail) unless obj["custom_data"][1] == ["spawn",["wpn_mp5_m1", "ammo_9x18_fmj = 3", "medkit", "bandage = 2", "af_cristall_flower"]]
  # else
  #   fail
  end.compact.map do |obj|
    x, z, y = obj["position"]
    # require "nokogiri"
    # name_s, name_p, fill, size, color = if obj["section_name"][/\Aaf_/]
    #   [obj["section_name"], ->_,__,___{_}, true, 95]
    # elsif treasures.include? obj["story_id"]
    #   [treasures[obj["story_id"]][1], ->_,__,___{ "#{_.join ", "} (\"#{
    #     Nokogiri::XML(File.read "out/config/text/#{__}/stable_treasure_manager.xml").at_css("##{treasures[obj["story_id"]][0]}").text.strip
    #   }\")".tap do |s|
    #     s.gsub!(/(\b\S.{25}\S*) (?=....)/, "\\1\n") if s.size >= 50
    #   end }, false, 70, [[160, 160, 160]]]
    # else
    #   [*case obj["custom_data"].size
    #   when 1 ; [obj["custom_data"][0][1][1][/\S+$/], ->_,__,___{ "#{_} (#{___} #{obj["custom_data"][0][1][0][/\S+$/]})" } ]
    #   when 2 ; ["af_cristall_flower",                ->_,__,___{ "#{_} (#{___} #{obj["section_name"]})" }                 ]
    #   else ; fail
    #   end, true, 85]
    # end
    [obj["section_name"], obj["section_name"], true, x, y, z, 50]
  end
end
# require "mll"
# pp MLL::tally[not_localized.map(&:first)].sort_by(&:last).last 10
not_localized.select! do |name_s, _, fill, x, y, z, size, color|
  rest.all? do |another|
    another.any? do |name_s_, _, fill_, x_, y_, z_, size_, color_|
      [name_s, fill, size, color, x, y, z] == [name_s_, fill_, size_, color_, x_, y_, z_] # && 0 >= Math.hypot(x - x_, y - y_)
    end
  end
end
# puts "ARTIFACTS: #{not_localized.size}"
# abort "< #{Fixtures.fetch(ARGV[1])[:ARTIFACTS]}" if not_localized.size < Fixtures.fetch(ARGV[1])[:ARTIFACTS]

# locale = "eng"

image = Render.prepare_image

# # data
# localize = lambda do |name|
#   YAML.load Nokogiri::XML(File.read "out/config/text/#{locale}/string_table_enc_zone.xml").at_css("##{
#     File.read("out/config/misc/artefacts.ltx", encoding: "CP1251").encode("utf-8", "cp1251").scan(/^\[([^\]]+).+\n(?:(?:[^\[\n].*)?\n)*inv_name\s*=\s*(\S+)/).to_h.fetch name
#   }").text.strip
# end
names = not_localized.sample(ARGV[11].to_i).map do |name_s, name_p, fill, x, y, z, size, color|
  # name_s = name_s.is_a?(String) ? localize[name_s] : name_s.map(&localize)
  image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2, fill: fill
  [name_s, *image.prepare_text(fx(x), fy(y), "#{name_s} #{x.round}:#{y.round}:#{z.round}", size, *color)]
end

# # legend
# strings = File.read("out/config/text/#{locale}/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
# image.image = image.image.composite2(*image.prepare_text(image.image.width - 400, 40, strings.fetch(ARGV[1]), 250)).flatten
# image.image = image.image.composite2(*image.prepare_text(image.image.width - 240, image.image.height - 40, "nakilon@gmail.com")).flatten
# x = y = 50
# image.image = image.image.composite2(*image.prepare_text(x, y, total, 160)).flatten
# y += 20
# require "mll"
# MLL::tally[names.flat_map(&:first)].sort_by(&:last).reverse.each do |m, c|
#   y += 15
#   image.image = image.image.composite2(*image.prepare_text(x, y, "#{c} x #{m}", 80)).flatten
# end
# y += 23
# image.image = image.image.draw_circle [255, 255, 255], x + 10, y, 3
# image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{stash}")).flatten
# y += 15
# image.image = image.image.draw_circle [255, 255, 255], x + 10, y, 3, fill: true
# image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{not_a} #{stash}")).flatten

# groups = []
# group = []
# queue = []
# until names.empty?
#   queue.push names.shift
#   until queue.empty?
#     group.push current = queue.shift
#     n1, _, t1, _, xy1 = *current
#     a, b = names.partition do |n2, _, t2, _, xy2|
#       n1 == n2 && (xy1[:y] + t1.height > xy2[:y]) &&
#                   (xy1[:y] < t2.height + xy2[:y]) &&
#                   (xy1[:x] + t1.width > xy2[:x]) &&
#                   (xy1[:x] < t2.width + xy2[:x])
#     end
#     queue.concat a
#     names.replace b
#   end
#   groups.push group
#   group = []
# end
# names = groups.map do |group|
#   next group.first.drop 2 if group.size == 1
#   x = group.map(&:last).sum{ |_| _[:x] } / group.size
#   y = group.map(&:last).sum{ |_| _[:y] } / group.size
#   text, mode, xy = *image.marker(x, y, "#{group.size}x #{group.first[0]}", 50, *color[group.first[1]])
#   [text, mode, x: x, y: y]
# end
# puts "#{groups.sum &:size} => #{names.size}"

require "istats"

moves = 0
begin
  moved = 0
  names.combination(2) do |name1, name2|
    n1, t1, _, xy1 = *name1
    n2, t2, _, xy2 = *name2
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
  moves += 1 unless moved.zero?
  puts "#{moved} texts moved"
  while 65 < t = IStats::Cpu.get_cpu_temp
    STDERR.puts "CPU temp = #{t}"
    sleep 2
  end
  while 5000 < t = IStats::Fan.get_fan_speed(0)
    STDERR.puts "FAN speed = #{t}"
    sleep 2
  end
end until moved.zero? || moved < 20 && moves > 10 unless ENV["SKIP"]

names.each do |_, *name|
  while 65 < t = IStats::Cpu.get_cpu_temp
    STDERR.puts "CPU temp = #{t}"
    sleep 2
  end
  while 5000 < t = IStats::Fan.get_fan_speed(0)
    STDERR.puts "FAN speed = #{t}"
    sleep 2
  end
  image.image = image.image.composite2(*name).flatten
end

image.image.write_to_file "debug.png"

puts "OK"
