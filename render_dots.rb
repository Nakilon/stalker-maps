require_relative "render"

image = Render.prepare_image "rus"

names = ALL.map do |obj|
  next if "space_restrictor" == obj["section_name"]
  x, z, y = obj["position"]
  image.image = image.image.draw_circle (
    # case obj[ARGV[2]]
    # when ARGV[3] ; [255, 96, 96]
    # when ARGV[4] ; [96, 96, 255]
    # when ARGV[5] ; [96, 255, 96]
    # else ; [255, 255, 255]
    # end

    # when -100..-3 ; [96, 255, 96]
    # when -3..5 ; [255, 96, 96]
    # when 5..16 ; [96, 96, 255]
    # else ; [255, 255, 255]

    # case z
    # # l10u
    # when -100..-12 ; [255, 96, 96]
    # when -12..100 ; [96, 255, 96]
    # else ; [255, 255, 255]
    # end

    # l12u_s
    case z
    when -5..10 ; [255, 96, 96]
    when 11..22 ; [96, 255, 96]
    else ; [255, 255, 255]
    end
  ), fx(x), fy(y), 2, fill: true
  obj["section_name"] = "d" if "physic_destroyable_object" == obj["section_name"]
  image.image = image.image.composite2(
    *image.prepare_text(
      fx(obj["position"][0]),
      fy(obj["position"][2]),
      obj["section_name"]
    )
  ).flatten unless obj["parent_id"]
end

image.image.write_to_file "temp.png"

puts "OK"
