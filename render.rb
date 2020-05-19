require "pp"
require "byebug"

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
abort if ALL.size < 1000

def fx x
  419 + x * 1.28
end
def fy y
  990 - y * 1.3725
end

require "vips"
Image = Struct.new :image do
  def prepare_text x, y, text, dpi = 100, color = [192, 192, 192]
    text = Vips::Image.text text, width: image.width - x - 7, dpi: dpi, font: "Verdana Bold"
    [
      text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text),
      :over, x: x + 7, y: y - 5
    ]
  end
  def marker x, y, text, dpi = 100, color = [192, 192, 192]
    text = Vips::Image.text text, width: image.width - x - 7, dpi: dpi, font: "Verdana Bold"
    text = text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text)
    [text, :over, x: x - text.width / 2, y: y - 5]
  end
end
