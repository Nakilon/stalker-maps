require_relative "render"

assert_empty = ->_{ fail if _.empty? }
treasures = File.read("out/config/misc/treasure_manager.ltx").gsub("\r\n", "\n").split(/^\[.+\n/).drop(2).map do |treasure|
  fail unless /\Atarget = (?<story_id>\d+)\n.+\ndescription = (?<description>.+)\nitems =(  = |\s*)(?<items>.+)\n/ =~ treasure
  next unless /af_/ =~ items
  [story_id.to_i, [description, items.split(", ").grep(/\Aaf_[a-z_-]+\z/).tap(&assert_empty)]]
end.compact.to_h

not_localized, *rest = [ALL, *ARGV[2,5].map(&YAML.method(:load_file))].map do |_|
  _.reject do |obj|
    next (fail if obj.to_s["af_"]) if treasures.include? obj["story_id"]
    next true unless obj.to_s["af_"]
    next if obj["section_name"][/\Aaf_/]
    (pp obj; fail) unless obj["custom_data"].is_a? Array
    case obj["custom_data"].size
    when 1
      (pp obj; fail) unless obj["custom_data"][0].size == 2
      case obj["custom_data"][0][0]
      when "drop_box"
        (pp obj; fail) unless obj["custom_data"][0][1].is_a? Array
        (pp obj; fail) unless obj["custom_data"][0][1].size == 2
        (pp obj; fail) unless obj["custom_data"][0][1][0][/\Acommunity = \S+_box\S*\z/]
        (pp obj; fail) unless obj["custom_data"][0][1][1][/\Aitems = af_[a-z_]+\z/]
      when "respawn"
        (pp obj; fail) unless obj["custom_data"][0][1].is_a? Array
        (pp obj; fail) unless obj["custom_data"][0][1].size == 4
        (pp obj; fail) unless obj["custom_data"][0][1][0] == "respawn_section = ammo_11.43x23_fmj,3,medkit,2,bandage,2,grenade_f1,2,af_cristall_flower"
        (pp obj; fail) unless obj["custom_data"][0][1][1] == "idle_spawn = -1"
        (pp obj; fail) unless obj["custom_data"][0][1][2] == "parent = 2031"
        (pp obj; fail) unless obj["custom_data"][0][1][3] == "item_spawn = true"
      else
        fail
      end
    when 2
      (pp obj; fail) unless obj["custom_data"][0] == ["dont_spawn_character_supplies", []] ||
                            obj["custom_data"][0] == ["smart_terrains", ["mil_freedom = {-aes_arrive_to}"]]
      (pp obj; fail) unless obj["custom_data"][1] == ["spawn",["wpn_mp5_m1", "ammo_9x18_fmj = 3", "medkit", "bandage = 2", "af_cristall_flower"]] ||
                            obj["custom_data"][1] == ["spawn", ["vodka = 4", "medkit = 5", "kolbasa = 3", "bread = 2", "conserva = 3", "antirad = 2", "bandage = 4", ";wpn_groza = 2", "af_cristall = 1"]]
    else
      fail
    end
  end.compact.flat_map do |obj|
    x, _, y = obj["position"]
    require "nokogiri"
    array = if obj["section_name"][/\Aaf_/]
      [[obj["section_name"], ->_,__,___{_}, true, 95]]
    elsif treasures.include? obj["story_id"]
      [[treasures[obj["story_id"]][1], ->_,__,___{ "#{_.join ", "} (\"#{
        Nokogiri::XML(File.read "out/config/text/#{__}/stable_treasure_manager.xml").at_css("##{treasures[obj["story_id"]][0]}").text.strip
      }\")".tap do |s|
        s.gsub!(/(\b\S.{25}\S*) (?=....)/, "\\1\n") if s.size >= 50
      end }, false, 70, [[160, 160, 160]]]]
    else
      case obj["custom_data"].size
      when 1
        case obj["custom_data"][0][0]
        when "drop_box"
          [[obj["custom_data"][0][1][1][/\S+$/], ->_,__,___{ "#{_} (#{___} #{obj["custom_data"][0][1][0][/\S+$/]})" }, true, 85]]
        when "respawn"
          obj["custom_data"][0][1][0][/\S+$/].split(?,).grep(/af_/).map do |item|
            [item, ->_,__,___{ "#{_} (#{___} #{obj["name"]})" }, true, 85]
          end
        else
          fail
        end
      when 2 ;
        [["af_cristall_flower", ->_,__,___{ "#{_} (#{___} #{obj["section_name"]})" }, true, 85]]
      else
        fail
      end
    end
    array.map do |name_s, name_p, fill, size, color|
      [name_s, name_p, fill, x, y, size, color]
    end
  end
end
not_localized.select! do |name_s, _, fill, x, y, size, color|
  rest.all? do |another|
    another.any? do |name_s_, _, fill_, x_, y_, size_, color_|
      [name_s, fill, size, color_] == [name_s_, fill_, size_, color_] && 0 >= Math.hypot(x - x_, y - y_)
    end
  end
end
puts "ARTIFACTS: #{not_localized.size}"
abort "< #{Fixtures.fetch(ARGV[1])[:ARTIFACTS]}" if not_localized.size < Fixtures.fetch(ARGV[1])[:ARTIFACTS]

[%w{ rus в Всего: секрет не }, %w{ eng in\ a Total: secret not\ a }].each do |locale, word, total, stash, not_a|
  image = Render.prepare_image locale

  # data
  localize = lambda do |name|
    YAML.load Nokogiri::XML(File.read "out/config/text/#{locale}/string_table_enc_zone.xml").at_css("##{
      File.read("out/config/misc/artefacts.ltx", encoding: "CP1251").encode("utf-8", "cp1251").scan(/^\[([^\]]+).+\n(?:(?:[^\[\n].*)?\n)*inv_name\s*=\s*(\S+)/).to_h.fetch name
    }").text.strip
  end
  names = not_localized.map do |name_s, name_p, fill, x, y, size, color|
    name_s = name_s.is_a?(String) ? localize[name_s] : name_s.map(&localize)
    image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2, fill: fill
    [name_s, name_p[name_s, locale, word], *image.prepare_text(fx(x), fy(y), name_p[name_s, locale, word], size, *color)]
  end

  # legend
  strings = File.read("out/config/text/#{locale}/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
  x = y = 50
  image.image = image.image.composite2(*image.prepare_text(x, y, total, 160)).flatten
  y += 20
  require "mll"
  MLL::tally[names.flat_map(&:first)].sort_by(&:last).reverse.each do |m, c|
    y += 15
    image.image = image.image.composite2(*image.prepare_text(x, y, "#{c} x #{m}", 80)).flatten
  end
  y += 23
  image.image = image.image.draw_circle [255, 255, 255], x + 10, y, 3
  image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{stash}")).flatten
  y += 15
  image.image = image.image.draw_circle [255, 255, 255], x + 10, y, 3, fill: true
  image.image = image.image.composite2(*image.prepare_text(x + 20, y, "#{not_a} #{stash}")).flatten

  begin
    moved = 0
    names.combination(2) do |name1, name2|
      _, n1, t1, _, xy1 = *name1
      _, n2, t2, _, xy2 = *name2
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
  end until moved.zero? unless ENV["SKIP"]

  names.each{ |_, _, *name| image.image = image.image.composite2(*name).flatten }

  image.image.write_to_file "rendered/#{ARGV[1]}_artifacts_#{locale}.jpg", Q: 95
end

puts "OK"
