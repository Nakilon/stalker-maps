require "pp"
require "byebug"

Fixtures = {
  "l01_escape" => {
    ALL: 1000,
    ARTIFACTS: 10,
    BG: "bg_l01.jpg",
  },
  "l02_garbage" => {
    ALL: 750,
    ARTIFACTS: 40,
    BG: "bg_l02.jpg",
  },
}

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
abort if ALL.size < Fixtures.fetch(ARGV[1])[:ALL]

case ARGV[1]
when "l01_escape"
  def fx x
    419 + x * 1.28
  end
  def fy y
    990 - y * 1.3725
  end
when "l02_garbage"
  def fx x
    810 + x * 2.65
  end
  def fy y
    846 - y * 2.78
  end
end
module Render
  require "vips"
  def self.prepare_image
    image = Vips::Image.new_from_file Fixtures.fetch(ARGV[1])[:BG]
    Struct.new :image do
      def prepare_text x, y, text, dpi = 100, color = [192, 192, 192]
        text = Vips::Image.text text, width: [image.width - x - 7, 0].max, dpi: dpi, font: "Verdana Bold"
        [
          text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text),
          :over, x: x + 7, y: y - 5
        ]
      end
      def marker x, y, text, dpi = 100, color = [192, 192, 192]
        text = Vips::Image.text text, width: [image.width - x - 7, 0].max, dpi: dpi, font: "Verdana Bold"
        text = text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text)
        [text, :over, x: x - text.width / 2, y: y - 5]
      end
    end.new case ARGV[1]
      when "l01_escape" ; image
      when "l02_garbage" ; image.resize 2, vscale: 2, kernel: :lanczos2
    end
  end
end

