require_relative "render"

assert_empty = ->_{ fail if _.empty? }
treasures = File.read("out/config/misc/treasure_manager.ltx").gsub("\r\n", "\n").split(/^\[.+\n/).drop(2).map do |treasure|
  fail unless /\Atarget = (?<story_id>\d+)\n.+\ndescription = (?<description>.+)\nitems =(  = |\s*)(?<items>.+)\n/ =~ treasure
  next unless /af_/ =~ items
  [story_id.to_i, [description, items.split(", ").grep(/\Aaf_[a-z_-]+\z/).tap(&assert_empty)]]
end.compact.to_h

objs = ALL.reject do |obj|
  next (fail if obj.to_s["af_"]) if treasures.include? obj["story_id"]
  next true unless obj.to_s["af_"]
  next if obj["section_name"][/\Aaf_/]
  (pp obj; fail) unless obj["custom_data"].is_a? Array
  case obj["custom_data"].size
  when 1
    (pp obj; fail) unless obj["custom_data"][0].size == 2
    (pp obj; fail) unless obj["custom_data"][0][0] == "drop_box"
    (pp obj; fail) unless obj["custom_data"][0][1].is_a? Array
    (pp obj; fail) unless obj["custom_data"][0][1].size == 2
    (pp obj; fail) unless obj["custom_data"][0][1][0][/\Acommunity = \S+_box\S*\z/]
    (pp obj; fail) unless obj["custom_data"][0][1][1][/\Aitems = af_[a-z_]+\z/]
  when 2
    (pp obj; fail) unless obj["custom_data"][0] == ["dont_spawn_character_supplies", []]
    (pp obj; fail) unless obj["custom_data"][1] == ["spawn",["wpn_mp5_m1", "ammo_9x18_fmj = 3", "medkit", "bandage = 2", "af_cristall_flower"]]
  else
    fail
  end
end.compact
puts "ARTIFACTS: #{objs.size}"
abort if objs.size < Fixtures.fetch(ARGV[1])[:ARTIFACTS]

[%w{ rus в Всего: тайник не }, %w{ eng in\ a Total: stash not\ a }].each do |locale, word, total, stash, not_a|
  image = Render.prepare_image

  # data
  names = objs.map do |obj|
    x, _, y = obj["position"]
    require "nokogiri"
    localize = lambda do |name|
      YAML.load Nokogiri::XML(File.read "out/config/text/#{locale}/string_table_enc_zone.xml").at_css("##{
        File.read("out/config/misc/artefacts.ltx", encoding: "CP1251").encode("utf-8", "cp1251").scan(/^\[([^\]]+).+\n(?:(?:[^\[\n].*)?\n)*inv_name\s*=\s*(\S+)/).to_h.fetch name
      }").text.strip
    end
    name_p, size, color = if obj["section_name"][/\Aaf_/]
      image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2, fill: true
      [(name_s = localize[obj["section_name"]]), 95]
    elsif treasures.include? obj["story_id"]
      image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2
      ["#{(name_s = treasures[obj["story_id"]][1].map &localize).join ", "} (\"#{
        Nokogiri::XML(File.read "out/config/text/#{locale}/stable_treasure_manager.xml").at_css("##{treasures[obj["story_id"]][0]}").text.strip
      }\")".tap do |s|
        s.gsub!(/(\b\S.{25}\S*) (?=....)/, "\\1\n") if s.size >= 50
      end, 70, [[160, 160, 160]]]
    else
      image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2, fill: true
      [case obj["custom_data"].size
      when 1 ; "#{name_s = localize[obj["custom_data"][0][1][1][/\S+$/]]} (#{word} #{obj["custom_data"][0][1][0][/\S+$/]})"
      when 2 ; "#{name_s = localize["af_cristall_flower"]} (#{word} #{obj["section_name"]})"
      else ; fail
      end, 85]
    end
    [name_s, name_p, *image.prepare_text(fx(x), fy(y), name_p, size, *color)]
  end

  # legend
  strings = File.read("out/config/text/#{locale}/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
  image.image = image.image.composite2(*image.prepare_text(image.image.width - 240, 40, strings.fetch(ARGV[1]), 250)).flatten
  image.image = image.image.composite2(*image.prepare_text(image.image.width - 240, image.image.height - 40, "nakilon@gmail.com")).flatten
  x = y = 50
  image.image = image.image.composite2(*image.prepare_text(x, y, total, 160)).flatten
  y += 20
  require "mll"
  MLL::tally[names.flat_map(&:first)].sort_by(&:last).reverse.each do |m, c|
    y += 15
    image.image = image.image.composite2(*image.prepare_text(x, y, "#{c} x #{m}", 80)).flatten
  end
  y += 20
  image.image = image.image.draw_circle [255, 255, 255], x + 10, y + 3, 3
  image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{stash}")).flatten
  y += 15
  image.image = image.image.draw_circle [255, 255, 255], x + 10, y + 3, 3, fill: true
  image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{not_a} #{stash}")).flatten

  begin
    moved = 0
    names.combination(2) do |name1, name2|
      _, n1, t1, _, xy1 = *name1
      _, n2, t2, _, xy2 = *name2
      next if n1.size == 1 || n2.size == 1
      next unless (xy1[:y] + t1.height > xy2[:y]) &&
                  (xy2[:y] + t2.height > xy1[:y]) &&
                  (xy1[:x] + t1.width  > xy2[:x]) &&
                  (xy2[:x] + t2.width  > xy1[:x])
      moved += 1
      if xy1[:y] + t1.height / 2.0 > xy2[:y] + t2.height / 2.0
        name1[4][:y] += 1
        name2[4][:y] -= 1
      else
        name1[4][:y] -= 1
        name2[4][:y] += 1
      end
    end
    puts "#{moved} texts moved"
  end until moved.zero?

  names.each{ |_, _, *name| image.image = image.image.composite2(*name).flatten }

  image.image.write_to_file "rendered/#{ARGV[1]}_artifacts_#{locale}.jpg", Q: 95
end

puts "OK"
