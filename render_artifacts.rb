require_relative "render"

objs = ALL.reject do |obj|
  next true unless obj.to_s["af_"]
  next if obj["section_name"][/\Aaf_/]
  (pp obj; fail) unless obj["custom_data"].is_a? Array
  (pp obj; fail) unless obj["custom_data"].size == 1
  (pp obj; fail) unless obj["custom_data"][0].size == 2
  (pp obj; fail) unless obj["custom_data"][0][0] == "drop_box"
  (pp obj; fail) unless obj["custom_data"][0][1].is_a? Array
  (pp obj; fail) unless obj["custom_data"][0][1].size == 2
  (pp obj; fail) unless obj["custom_data"][0][1][0][/\Acommunity = \S+_box\S*\z/]
  (pp obj; fail) unless obj["custom_data"][0][1][1][/\Aitems = af_[a-z_]+\z/]
end.compact
puts "ARTIFACTS: #{objs.size}"
abort if objs.size < 10

[%w{ rus в Всего: }, %w{ eng in Total: }].each do |locale, word, total|
  image = Image.new Vips::Image.new_from_file ARGV[1]

  # data
  names = objs.map do |obj|
    x, _, y = obj["position"]
    require "nokogiri"
    image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 2, fill: true
    localize = lambda do |name|
      YAML.load Nokogiri::XML(File.read "out/config/text/#{locale}/string_table_enc_zone.xml").at_css("##{
        File.read("out/config/misc/artefacts.ltx", encoding: "CP1251").encode("utf-8", "cp1251").scan(/^\[([^\]]+).+\n(?:(?:[^\[\n].*)?\n)*inv_name\s*=\s*(\S+)/).to_h.fetch name
      }").text.strip
    end
    name_p = obj["section_name"][/\Aaf_/] ?
      (name_s = localize[obj["section_name"]]) :
      "#{name_s = localize[obj["custom_data"][0][1][1][/\S+$/]]} (#{word} #{obj["custom_data"][0][1][0][/\S+$/]})"
    [name_s, name_p, *image.prepare_text(fx(x), fy(y), name_p, 100)]
  end.compact

  # legend
  strings = File.read("out/config/text/#{locale}/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
  image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, 50, strings.fetch(ARGV[2]), 250)).flatten
  image.image = image.image.composite2(*image.prepare_text(image.image.width - 250, image.image.height - 50, "nakilon@gmail.com")).flatten
  x = y = 50
  image.image = image.image.composite2(*image.prepare_text(x + 10, y, total, 160)).flatten
  y += 18
  require "mll"
  MLL::tally[names.map(&:first)].sort_by(&:last).reverse.each do |m, c|
    y += 12
    image.image = image.image.composite2(*image.prepare_text(x + 10, y, "#{c}x #{m}", 80)).flatten
  end

  begin
    moved = 0
    names.permutation(2) do |name1, name2|
      _, n1, t1, _, xy1 = *name1
      _, n2, t2, _, xy2 = *name2
      next if n1.size == 1 || n2.size == 1
      next unless (xy1[:y] + t1.height > xy2[:y]) &&
                  (xy1[:y]             < xy2[:y]) &&
                  (xy1[:x] + t1.width  > xy2[:x]) &&
                  (xy1[:x] < t2.width  + xy2[:x])
      moved += 1
      name1[4][:y] -= 1
      name2[4][:y] += 1
    end
    puts "#{moved} texts moved"
  end until moved.zero?

  names.each{ |_, _, *name| image.image = image.image.composite2(*name).flatten }

  image.image.write_to_file "rendered/#{ARGV[2]}_artifacts_#{locale}.png"
end

puts "OK"
