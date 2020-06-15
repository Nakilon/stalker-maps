require_relative "render"

mutants = ALL.select do |item|
  next unless /\Amonsters\\/ =~ item["visual_name"] && "physic_object" != item["section_name"]
  true
end.compact
puts "MUTANTS: #{mutants.size}"
abort "< #{Fixtures.fetch(ARGV[1])[:MUTANTS]}" if mutants.size < Fixtures.fetch(ARGV[1])[:MUTANTS]


[%w{ rus Всего: }, %w{ eng Total: }].each do |locale, total|
  image = Render.prepare_image locale

  color = lambda do |name|
    hsv_to_rgb = lambda do |h, s, v|
        vmin = (100 - s) * v / 100
        a = (v - vmin) * (h % 60) / 60.0
        vinc = vmin + a
        vdec = v - a
        case h / 60
        when 0 ; [v, vinc, vmin]
        when 1 ; [vdec, v, vmin]
        when 2 ; [vmin, v, vinc]
        when 3 ; [vmin, vdec, v]
        when 4 ; [vinc, vmin, v]
        when 5 ; [v, vmin, vdec]
        end.map{ |i| (2.55 * i).round }
    end
    {
      "m_dog_e" => [hsv_to_rgb[20, 50, 90]],
      "dog_weak" => [hsv_to_rgb[20, 50, 90]],
      "dog_normal" => [hsv_to_rgb[20, 50, 90]],
      "dog_strong" => [hsv_to_rgb[20, 50, 90]],
      "boar_weak" => [hsv_to_rgb[150, 50, 70]],
      "boar_normal" => [hsv_to_rgb[150, 50, 70]],
    }[name]
  end

  # data
  names = mutants.map do |obj|
    health = obj["health"] || obj["upd:health"]
    fail obj["id"].to_s unless health
    fail if obj["community_index"]
    x, _, y = obj["position"]
    fail if obj["character_name"]
    require "nokogiri"
    name = if localized = Nokogiri::XML::DocumentFragment.parse(File.read("out/config/text/#{locale}/stable_statistic_caption.xml", encoding: "CP1251").encode("utf-8", "cp1251")).at_css(
      "##{obj["section_name"]}"
    )
      YAML.load localized.text.strip
    else
      obj["section_name"]
    end
    [name, obj["section_name"], *image.marker(fx(x), fy(y), name, 80, *color[obj["section_name"]])]
  end.compact

  # legend
  x = y = 50
  require "mll"
  image.image = image.image.composite2(*image.prepare_text(x + 10, y, total, 160)).flatten
  y += 20
  MLL::tally[names.transpose[0,2].transpose].sort_by(&:last).reverse.each do |m, c|
    y += 15
    image.image = image.image.composite2(*image.prepare_text(x + 10, y, "#{c} x #{m[0]}", 80, *color[m[1]])).flatten
  end

  groups = []
  group = []
  queue = []
  until names.empty?
    queue.push names.shift
    until queue.empty?
      group.push current = queue.shift
      n1, _, t1, _, xy1 = *current
      a, b = names.partition do |n2, _, t2, _, xy2|
        n1 == n2 && (xy1[:y] + t1.height > xy2[:y]) &&
                    (xy1[:y] < t2.height + xy2[:y]) &&
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
    next group.first.drop 2 if group.size == 1
    # TODO: maybe somehow do not init Vips object until here
    x = group.map(&:last).sum{ |_| _[:x] } / group.size
    y = group.map(&:last).sum{ |_| _[:y] } / group.size
    text, mode, xy = *image.marker(x, y, "#{group.size}x #{group.first[0]}", 80, *color[group.first[1]])
    [text, mode, x: x, y: y]
  end
  puts "#{groups.sum &:size} => #{names.size}"

  begin
    moved = 0
    names.permutation(2) do |name1, name2|
      t1, _, xy1 = *name1
      t2, _, xy2 = *name2
      next unless (xy1[:y] + t1.height > xy2[:y]) &&
                  (xy2[:y] + t2.height > xy1[:y]) &&
                  (xy1[:x] + t1.width  > xy2[:x]) &&
                  (xy2[:x] + t2.width  > xy1[:x])
      moved += 1
      if xy1[:y] + t1.height / 2.0 > xy2[:y] + t2.height / 2.0
        name1[2][:y] += 1
        name2[2][:y] -= 1
      else
        name1[2][:y] -= 1
        name2[2][:y] += 1
      end
    end
    puts "#{moved} texts moved"
  end until moved.zero?
  names.each{ |name| image.image = image.image.composite2(*name).flatten }

  image.image.write_to_file "rendered/#{ARGV[1]}_mutants_#{locale}.jpg", Q: 95
end


puts "OK"
