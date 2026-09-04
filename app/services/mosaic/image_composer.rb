require "vips"
require "tempfile"
require "securerandom"

module Mosaic
  class ImageComposer

    # 1ピースあたりの最終出力サイズ（px）。偶数にすること（2×2に分割して描画するため）
    PIECE_PX = 80

    def initialize(mosaic_art)
      @mosaic_art = mosaic_art
      @mosaic_design = mosaic_art.mosaic_design
      @area_size_x = mosaic_design.area_size_x
      @area_size_y = mosaic_design.area_size_y
      # サブブロック（tl/tr/bl/br）単位のグリッドサイズ。1ピース = 2×2サブブロック
      @grid_width = @area_size_x * 2
      @grid_height = @area_size_y * 2
    end


    # @return [String] 生成したPNG画像の一時ファイルパス（呼び出し元で削除すること）
    def call
      # サブブロック1個 = １px の小さいキャンバスに、design_pieceの色を敷き詰める
      small_image = build_small_grid_image # 小さいキャンバスを作成
      scale = PIECE_PX / 2.0 # 小さいキャンバスを2倍に拡大
      resized = small_image.resize(scale, kernel: :nearest) # 小さいキャンバスを2倍に拡大

      path = File.join(Dir.tmpdir, "mosaic_art_#{@mosaic_art.id}_#{SecureRandom.hex(4)}.png") # 一時ファイルパスを生成
      resized.write_to_file(path) # 小さいキャンバスを2倍に拡大した画像を保存
      path # 一時ファイルパスを返す
    end

    private

    # サブブロック1個 = １px の小さいキャンバスに、design_pieceの色を敷き詰める
    def build_small_grid_image
      # サブブロックの位置ごとにdesign_pieceを取得
      design_pieces_by_position = @mosaic_design.design_pieces.index_by(&:position)
      # サブブロック1個 = １px の小さいキャンバスを作成
      base = Vips::Image.block(@grid_width, @grid_height, bands: 3)

      # サブブロックの位置ごとにdesign_pieceの色を敷き詰める
      base.mutate do |mutable|
        # サブブロックの行ごとに処理
        @area_size_y.times do |piece_row|
          # サブブロックの列ごとに処理
          @area_size_x.times do |piece_col|
            # サブブロックの位置を計算
            position = piece_row * @area_size_x + piece_col
            # サブブロックの位置に対応するdesign_pieceを取得
            design_piece = design_pieces_by_position[position]
            # design_pieceが存在しない場合はスキップ
            next unless design_piece

            # design_pieceの色を取得
            tl, tr, bl, br = design_piece.color
            # サブブロックの位置を計算
            x = piece_col * 2
            y = piece_row * 2
            # サブブロックの位置に対応するdesign_pieceの色を敷き詰める
            mutable.draw_rect!(hex_to_rgb(tl), x,     y,     1, 1, fill: true) # 左上
            mutable.draw_rect!(hex_to_rgb(tr), x + 1, y,     1, 1, fill: true) # 右上
            mutable.draw_rect!(hex_to_rgb(bl), x,     y + 1, 1, 1, fill: true) # 左下
            mutable.draw_rect!(hex_to_rgb(br), x + 1, y + 1, 1, 1, fill: true) # 右下
          end
        end
      end
    end

    # "#RRGGBB" → [R, G, B](0-255の配列)に変換
    def hex_to_rgb(hex_color)
      # "#RRGGBB" → "RRGGBB" に変換
      hex = hex_color.delete("#")
      # "RRGGBB" → [R, G, B](0-255の配列)に変換
      [ hex[0..1], hex[2..3], hex[4..5] ].map { |part| part.to_i(16) }
    end
  end
end