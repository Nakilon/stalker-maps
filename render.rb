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
  def prepare_text x, y, text, dpi = 100
    text = Vips::Image.text text, width: image.width - x - 7, dpi: dpi, font: "Verdana Bold"
    [
      text.new_from_image([192, 192, 192]).copy(interpretation: :srgb).bandjoin(text),
      :over, x: x + 7, y: y - 5
    ]
  end
end
