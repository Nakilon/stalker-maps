require "pp"
require "byebug"

Fixtures = {
  "l01_escape" => {
    ALL: 1000,
    NPCS: 50,
    MUTANTS: 100,
    ANOMALIES: 150,
    ARTIFACTS: 19,
    BG: "bg_l01.png",
    FXA: 458, FXB: 1.35, FYA: 1190, FYB: 1.3725,
    TOP: 200, HEIGHT: 1600,
  },
  "l02_garbage" => {
    ALL: 750,
    NPCS: 50,
    MUTANTS: 40,
    ANOMALIES: 150,
    ARTIFACTS: 40,
    BG: "bg_l02.jpg",
    FXA: 810, FXB: 2.65, FYA: 846, FYB: 2.78,
  },
  "l03_agroprom" => {
    ALL: 750,
    NPCS: 30,
    MUTANTS: 25,
    ANOMALIES: 100,
    ARTIFACTS: 13,
    BG: "bg_l03.jpg",
    FXA: 725, FXB: 2.69, FYA: 625, FYB: 2.925,
  },
  "l03u_agr_underground" => {
    ALL: 250,
    NPCS: 19,
    MUTANTS: 2,
    ANOMALIES: 25,
    ARTIFACTS: 11,
    BG: "bg_l03u.jpg",
    FXA: 1140, FXB: 8.35, FYA: 415, FYB: 8.265,
  },
}

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
abort "< #{Fixtures.fetch(ARGV[1])[:ALL]}" if ALL.size < Fixtures.fetch(ARGV[1])[:ALL]

def fx x
  Fixtures.fetch(ARGV[1])[:FXA] + x * Fixtures.fetch(ARGV[1])[:FXB]
end
def fy y
  Fixtures.fetch(ARGV[1])[:FYA] - y * Fixtures.fetch(ARGV[1])[:FYB] - (Fixtures.fetch(ARGV[1])[:TOP] || 0)
end

module Render
  require "vips"
  def self.prepare_image
    image = case ARGV[1]
      when "l01_escape"
        Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).flatten.tap do |image|
          left, top, width, height = Fixtures.fetch(ARGV[1]).values_at :LEFT, :TOP, :WIDTH, :HEIGHT
          break image.crop left || 0, top || 0, width || image.width, [(height || image.height), image.height - (top || 0)].min
        end
      when "l02_garbage" ; Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).resize 2, vscale: 2, kernel: :lanczos2
      when "l03_agroprom" ; Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).resize 2, vscale: 2, kernel: :lanczos2
      when "l03u_agr_underground"
        Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential).tap do |image|
          break image.embed 0, 0, image.width + 20, image.height, background: image.shrink(image.width, image.height).getpoint(0, 0)
        end.resize 4, vscale: 4, kernel: :lanczos2
      else ; fail
    end
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
    end.new image
  end
end
