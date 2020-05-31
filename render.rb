require "pp"
require "byebug"

Fixtures = {
  "l01_escape" => {
    ALL: 1000,
    ARTIFACTS: 10,
    MUTANTS: 100,
    BG: "bg_l01.png",
    FXA: 458, FXB: 1.35, FYA: 1190, FYB: 1.3725,
  },
  "l02_garbage" => {
    ALL: 750,
    ARTIFACTS: 40,
    MUTANTS: 40,
    BG: "bg_l02.jpg",
    FXA: 810, FXB: 2.65, FYA: 846, FYB: 2.78,
  },
}

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
abort if ALL.size < Fixtures.fetch(ARGV[1])[:ALL]

def fx x
  Fixtures.fetch(ARGV[1])[:FXA] + x * Fixtures.fetch(ARGV[1])[:FXB]
end
def fy y
  Fixtures.fetch(ARGV[1])[:FYA] - y * Fixtures.fetch(ARGV[1])[:FYB]
end

module Render
  require "vips"
  def self.prepare_image
    Struct.new :image do
      def prepare_text x, y, text, dpi = 100, color = [192, 192, 192]
        text = Vips::Image.text text, width: [image.width - x - 7, 0].max, dpi: dpi, font: "Verdana Bold"
        [
          text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text),
          :over, x: x + 7, y: y - 5
        ]
      end
      def marker x, y, text, dpi = 100, color = [192, 192, 192]
        text = Vips::Image.text text, width: [image.width - x, 0].max, dpi: dpi, font: "Verdana Bold"
        text = text.new_from_image(color).copy(interpretation: :srgb).bandjoin(text)
        [text, :over, x: x - text.width / 2, y: y - 5]
      end
    end.new case ARGV[1]
      when "l01_escape" ; Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).flatten
      when "l02_garbage" ; Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).resize 2, vscale: 2, kernel: :lanczos2
    end
  end
end
