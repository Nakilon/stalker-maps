require "pp"
require "byebug"

Fixtures = {
  "l01_escape" => {
    ALL: 1000, NPCS: 50, MUTANTS: 100, ANOMALIES: 150, ARTIFACTS: 18,
    BG: "bg_l01.png",
    FXA: 458, FXB: 1.35, FYA: 1190, FYB: 1.3725,
    TOP: 200, HEIGHT: 1600,
  },
  "l02_garbage" => {
    ALL: 750, NPCS: 60, MUTANTS: 40, ANOMALIES: 150, ARTIFACTS: 40,
    BG: "bg_l02.jpg",
    FXA: 810, FXB: 2.65, FYA: 846, FYB: 2.78,
    RESIZE: 2,
  },
  "l03_agroprom" => {
    ALL: 750, NPCS: 60, MUTANTS: 25, ANOMALIES: 100, ARTIFACTS: 13,
    BG: "bg_l03.jpg",
    FXA: 725, FXB: 2.69, FYA: 625, FYB: 2.925,
    RESIZE: 2,
  },
  "l03u_agr_underground" => {
    ALL: 250, NPCS: 20, MUTANTS: 2, ANOMALIES: 25, ARTIFACTS: 11,
    BG: "bg_l03u.jpg",
    FXA: 1140, FXB: 8.35, FYA: 415, FYB: 8.265,
  },
  "l04_darkvalley" => {
    ALL: 1000, NPCS: 90, MUTANTS: 75, ANOMALIES: 50, ARTIFACTS: 20,
    BG: "bg_l04.jpg",
    FXA: 971, FXB: 2.875, FYA: 420, FYB: 3.075,
    LEFT: 350, WIDTH: 1400, TOP: 150, HEIGHT: 2000,
    RESIZE: 2,
  },
  "l04u_labx18" => {
    ALL: 300, NPCS: 8, MUTANTS: 9, ANOMALIES: 12, ARTIFACTS: 3,
    BG: "bg_l04u.jpg",
    FXA: 515, FXB: 10, FYA: 680, FYB: 8.5,
  },
  "l05_bar" => {
    ALL: 600, NPCS: 50, MUTANTS: 35, ANOMALIES: 9, ARTIFACTS: 6,
    BG: "bg_l05.jpg",
    FXA: -60, FXB: 3.7, FYA: 1110, FYB: 4,
    WIDTH: 1100, TOP: 360, HEIGHT: 1400,
    RESIZE: 2,
  },
  "l06_rostok" => {
    ALL: 700, NPCS: 47, MUTANTS: 14, ANOMALIES: 50, ARTIFACTS: 20,
    BG: "bg_l06.jpg",
    FXA: 1236, FXB: 2.65, FYA: 823, FYB: 2.75,
    LEFT: 100, WIDTH: 1400, TOP: 100, HEIGHT: 1400,
    RESIZE: 2,
  },
  "l07_military" => {
    ALL: 1000, NPCS: 40, MUTANTS: 50, ANOMALIES: 150, ARTIFACTS: 17,
    BG: "bg_l07.jpg",
    FXA: 1129, FXB: 2.65, FYA: 1444, FYB: 2.825,
    LEFT: 50, WIDTH: 1500, HEIGHT: 1700,
    RESIZE: 2,
  },
  "l08_yantar" => {
    ALL: 500, NPCS: 5, MUTANTS: 30, ANOMALIES: 2, ARTIFACTS: 14,
    BG: "bg_l08.jpg",
    FXA: 532, FXB: 2.55, FYA: 432, FYB: 2.69,
    WIDTH: 1150, TOP: 200, HEIGHT: 1200,
    RESIZE: 2,
  },
}

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
if ARGV[1][/\A(\d+)x(\d+)\z/]
  def fx x
    ARGV[7].to_i + x * ARGV[8].to_i
  end
  def fy y
    ARGV[9].to_i - y * ARGV[10].to_i
  end
else
  abort "< #{Fixtures.fetch(ARGV[1])[:ALL]}" if ALL.size < Fixtures.fetch(ARGV[1])[:ALL]
  def fx x
    Fixtures.fetch(ARGV[1])[:FXA] + x * Fixtures.fetch(ARGV[1])[:FXB] - (Fixtures.fetch(ARGV[1])[:LEFT] || 0)
  end
  def fy y
    Fixtures.fetch(ARGV[1])[:FYA] - y * Fixtures.fetch(ARGV[1])[:FYB] - (Fixtures.fetch(ARGV[1])[:TOP] || 0)
  end
end

module Render
  require "vips"
  def self.prepare_image locale
    loaded = Vips::Image.new_from_file(Fixtures.fetch(ARGV[1])[:BG], access: :sequential)
    loaded = loaded.resize(2, vscale: 2, kernel: :lanczos2) if Fixtures.fetch(ARGV[1]).include? :RESIZE
    left, top, width, height = Fixtures.fetch(ARGV[1]).values_at :LEFT, :TOP, :WIDTH, :HEIGHT
    loaded = loaded.crop left || 0, top || 0, width || loaded.width, height || loaded.height
    image = case ARGV[1]
      when "l01_escape", "l02_garbage", "l03_agroprom", "l04_darkvalley", "l07_military"
        loaded
      when "l05_bar", "l06_rostok", "l08_yantar"
        loaded * 0.7
      when "l04u_labx18"
        loaded * [1, 0.85, 1]
      when "l03u_agr_underground"
        loaded.embed(0, 0, loaded.width + 20, loaded.height, background: loaded.shrink(loaded.width, loaded.height).getpoint(0, 0)).resize 4, vscale: 4, kernel: :lanczos2
      when /\A(\d+)x(\d+)\z/
        Vips::Image.black $1.to_i, $2.to_i
      else
        fail
    end
    Struct.new :image do
      def prepare_text_only x, text, dpi
        Vips::Image.text text, width: [image.width - x - 7, 0].max, dpi: dpi, font: "Verdana Bold"
      end
      def prepare_text x, y, text, dpi = 100, color = [192, 192, 192]
        text = prepare_text_only(x, text, dpi)
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
    end.new(image).tap do |image|
      strings = File.read("out/config/text/#{locale}/string_table_general.xml", encoding: "CP1251").encode("utf-8", "cp1251").scan(/([^"]+)">..+?>([^<]+)/m).to_h
      image.image = image.image.composite2(*image.prepare_text(image.image.width - image.prepare_text_only(0, strings.fetch(ARGV[1]), 200).width - 50, 40, strings.fetch(ARGV[1]), 200)).flatten
      image.image = image.image.composite2(*image.prepare_text(image.image.width - 240, image.image.height - 40, "nakilon@gmail.com")).flatten
    end
  end
end
