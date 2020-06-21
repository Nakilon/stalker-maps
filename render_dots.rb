require_relative "render"

image = Render.prepare_image "rus"

names = ALL.map do |obj|
  x, z, y = obj["position"]
  image.image = image.image.draw_circle (
    case obj["section_name"]
    when ARGV[2] ; [255, 96, 96]
    when ARGV[3] ; [96, 96, 255]
    when ARGV[4] ; [96, 255, 96]
    else ; [255, 255, 255]
    end
  ), fx(x), fy(y), 1, fill: true
end

image.image.write_to_file "temp.png"

puts "OK"
