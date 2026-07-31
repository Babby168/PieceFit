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

      resized_path = resize_with_nearest_neighbor
      quantized_path = quantize_colors(resized_path)
      pixel_map = read_pixels(quantized_path)
      build_position_color_map(pixel_map)
    ensure
      [ resized_path, quantized_path ].compact.each { |path| File.delete(path) if File.exist?(path) }
    end

    private

    def resize_with_nearest_neighbor
      image = Vips::Image.new_from_file(@source_path)
      image = image.flatten(background: [ 255, 255, 255 ]) if image.has_alpha?

      scale = @grid_width.to_f / image.width
      vscale = @grid_height.to_f / image.height
      resized = image.resize(scale, vscale: vscale, kernel: :nearest)

      path = File.join(Dir.tmpdir, "mosaic_resized_#{Process.pid}_#{SecureRandom.hex(4)}.png")
      resized.write_to_file(path)
      path
    end

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
