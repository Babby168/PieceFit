# frozen_string_literal: true

require "mini_magick"
require "vips"
require "tempfile"
require "securerandom"

module Mosaic
  class ColorExtractor
    SUB_SLOTS = [ :top_left, :top_right, :bottom_left, :bottom_right ].freeze
    DEFAULT_PALETTE_SIZE = 24

    def initialize(source_path:, area_size_x: 10, area_size_y: 9, palette_size: DEFAULT_PALETTE_SIZE)
      @source_path = source_path.to_s
      @area_size_x = area_size_x
      @area_size_y = area_size_y
      @palette_size = palette_size
      @grid_width = area_size_x * 2
      @grid_height = area_size_y * 2
    end

    # @return [Hash{Integer => Array<String>}] position(0..) => [tl, tr, bl, br]
    def call
      resized_path = nil
      quantized_path = nil

      resized_path = resize_cover_crop_then_nearest
      quantized_path = quantize_colors(resized_path)
      pixel_map = read_pixels(quantized_path)
      build_position_color_map(pixel_map)
    ensure
      [ resized_path, quantized_path ].compact.each { |path| File.delete(path) if File.exist?(path) }
    end

    private

    # アスペクト比を維持しながら、グリッドサイズに合わせてリサイズした後、nearestでリサイズする
    def resize_cover_crop_then_nearest
      image = Vips::Image.new_from_file(@source_path)
      image = image.flatten(background: [ 255, 255, 255 ]) if image.has_alpha?

      # target_ratio: 20/18 ≒ 10/9
      # source_ratio: 10/9
      target_ratio = @grid_width.to_f / @grid_height  # 20/18 ≒ 10/9
      source_ratio = image.width.to_f / image.height

      if source_ratio > target_ratio
        # 元が横長 → 左右を切る
        new_width = (image.height * target_ratio).round
        left = (image.width - new_width) / 2
        image = image.crop(left, 0, new_width, image.height)
      else
        # 元が縦長 → 上下を切る
        new_height = (image.width / target_ratio).round
        top = (image.height - new_height) / 2
        image = image.crop(0, top, image.width, new_height)
      end

      # リサイズ
      resized = image.resize(
        @grid_width.to_f / image.width,
        vscale: @grid_height.to_f / image.height,
        kernel: :nearest
      )

      # パスを作成
      path = File.join(Dir.tmpdir, "mosaic_resized_#{Process.pid}_#{SecureRandom.hex(4)}.png")
      # パスに書き出し
      resized.write_to_file(path)
      # パスを返す
      path
    end

    # 減色
    def quantize_colors(input_path)
      image = MiniMagick::Image.open(input_path)
      image.combine_options do |c|
        c.colors @palette_size.to_s
        c.dither "None"
      end

      output_path = "#{input_path}.quantized.png"
      image.write(output_path)
      output_path
    end

    # ピクセルを読み込む
    def read_pixels(path)
      image = Vips::Image.new_from_file(path)
      image = image.flatten(background: [ 255, 255, 255 ]) if image.has_alpha?

      Array.new(@grid_height) do |y|
        Array.new(@grid_width) do |x|
          r, g, b = image.getpoint(x, y)
          format("#%02X%02X%02X", r.round, g.round, b.round)
        end
      end
    end

    # 位置と色のマップを作成する
    def build_position_color_map(pixel_map)
      result = {}
      @area_size_y.times do |piece_row|
        @area_size_x.times do |piece_col|
          position = piece_row * @area_size_x + piece_col
          tl = pixel_map[piece_row * 2][piece_col * 2]
          tr = pixel_map[piece_row * 2][piece_col * 2 + 1]
          bl = pixel_map[piece_row * 2 + 1][piece_col * 2]
          br = pixel_map[piece_row * 2 + 1][piece_col * 2 + 1]
          result[position] = [ tl, tr, bl, br ]
        end
      end
      result
    end
  end
end
