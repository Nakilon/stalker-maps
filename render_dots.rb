require_relative "render"

image = Render.prepare_image "rus"

names = ALL.map do |obj|
  x, z, y = obj["position"]
  image.image = image.image.draw_circle (
    case z
    # when -100..-3 ; [96, 255, 96]
    # when -3..5 ; [255, 96, 96]
    # when 5..16 ; [96, 96, 255]
    # else ; [255, 255, 255]

    # l10u
    when -100..-12 ; [255, 96, 96]
    when -12..100 ; [96, 255, 96]
    else ; [255, 255, 255]

    end
  ), fx(x), fy(y), 2, fill: true
end

image.image.write_to_file "temp.png"

puts "OK"
