require_relative "render"

image = Render.prepare_image "rus"

names = ALL.map do |obj|
  x, z, y = obj["position"]
  image.image = image.image.draw_circle [255, 255, 255], fx(x), fy(y), 1
end

image.image.write_to_file "temp.png"

puts "OK"
