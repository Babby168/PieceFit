class MypageController < ApplicationController
  def index
    # ログイン中のユーザーの持つ作成済みのモザイクアートのうち、最新のものを取得
    # もし存在しなければ、デザイン１件分のPieceを作って進捗を開始する
    @mosaic_art = current_user.mosaic_arts.order(:created_at).last || build_current_mosaic_art
    # モザイクアートのデザイン情報を取得
    @mosaic_design = @mosaic_art.mosaic_design
    # デザインピースの情報を取得
    @design_pieces_by_position = @mosaic_design.design_pieces.index_by(&:position)
    # ピースの獲得状況を取得
    @pieces_by_position = @mosaic_art.pieces.index_by(&:position)
  end

  private

  # 進行中の作品がまだ無ければ、デザイン１件分のPieceを作って進捗を開始する
  # (ピース獲得ロジック自体は issue #38 で実装)
  def build_current_mosaic_art
    # デザイン１件分のPieceを作って進捗を開始する
    design = MosaicDesign.first
    # モザイクアートを作成して進捗を開始する
    mosaic_art = current_user.mosaic_arts.create!(mosaic_design: design)
    # デザインピースの情報を取得
    design.design_pieces.find_each do |design_piece|
      # ピースを作成して進捗を開始する
      mosaic_art.pieces.create!(position: design_piece.position)
    end
    # モザイクアートを返す
    mosaic_art
  end
end
