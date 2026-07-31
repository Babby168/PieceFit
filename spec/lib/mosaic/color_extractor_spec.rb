require "rails_helper"

RSpec.describe Mosaic::ColorExtractor do
  describe "#build_position_color_map" do
    it "2x2サブピクセルを position ごとの4色配列へマッピングすること" do
      extractor = described_class.new(
        source_path: "unused.png",
        area_size_x: 2,
        area_size_y: 2
      )

      pixel_map = [
        [ "#AA0000", "#BB0000", "#CC0000", "#DD0000" ],
        [ "#AA1111", "#BB1111", "#CC1111", "#DD1111" ],
        [ "#AA2222", "#BB2222", "#CC2222", "#DD2222" ],
        [ "#AA3333", "#BB3333", "#CC3333", "#DD3333" ]
      ]

      result = extractor.send(:build_position_color_map, pixel_map)

      expect(result.size).to eq(4)
      expect(result[0]).to eq([ "#AA0000", "#BB0000", "#AA1111", "#BB1111" ])
      expect(result[1]).to eq([ "#CC0000", "#DD0000", "#CC1111", "#DD1111" ])
      expect(result[2]).to eq([ "#AA2222", "#BB2222", "#AA3333", "#BB3333" ])
      expect(result[3]).to eq([ "#CC2222", "#DD2222", "#CC3333", "#DD3333" ])
    end
  end

  describe "#call" do
    it "指定グリッド数のピース色を返すこと" do
      unless image_tools_available?
        skip "libvips / ImageMagick が利用できない環境ではスキップ"
      end

      source_path = Rails.root.join("tmp/mosaic_color_extractor_fixture.png")
      FileUtils.mkdir_p(File.dirname(source_path))

      # 4x4 = area_size 2x2 の見た目解像度。各ピクセルを既知色にする
      colors = [
        [ [ 255, 0, 0 ], [ 0, 255, 0 ], [ 0, 0, 255 ], [ 255, 255, 0 ] ],
        [ [ 255, 0, 255 ], [ 0, 255, 255 ], [ 128, 0, 0 ], [ 0, 128, 0 ] ],
        [ [ 0, 0, 128 ], [ 128, 128, 0 ], [ 128, 0, 128 ], [ 0, 128, 128 ] ],
        [ [ 64, 64, 64 ], [ 192, 192, 192 ], [ 255, 128, 0 ], [ 0, 128, 255 ] ]
      ]
      pixels = colors.flatten
      image = Vips::Image.new_from_memory(pixels.pack("C*"), 4, 4, 3, :uchar)
      image.write_to_file(source_path.to_s)

      result = described_class.new(
        source_path: source_path,
        area_size_x: 2,
        area_size_y: 2,
        palette_size: 24
      ).call

      expect(result.keys).to match_array((0..3).to_a)
      result.each_value do |color|
        expect(color.size).to eq(4)
        expect(color).to all(match(/\A#[0-9A-F]{6}\z/))
      end
    ensure
      File.delete(source_path) if source_path && File.exist?(source_path)
    end
  end

  def image_tools_available?
    require "vips"
    require "mini_magick"
    Vips::VERSION.present? && MiniMagick.cli_version.present?
  rescue LoadError, MiniMagick::Error, Errno::ENOENT
    false
  end
end
