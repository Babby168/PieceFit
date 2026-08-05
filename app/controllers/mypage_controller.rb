class MypageController < ApplicationController
  def index
    # ピース獲得ロジックを呼び出して、現在のモザイクアートを取得
    @mosaic_art = PieceAcquisitionService.new(current_user).ensure_current_mosaic_art!
    # モザイクアートのデザイン情報を取得
    @mosaic_design = @mosaic_art.mosaic_design
    # デザインピースの情報を取得
    @design_pieces_by_position = @mosaic_design.design_pieces.index_by(&:position)
    # ピースの獲得状況を取得
    @pieces_by_position = @mosaic_art.pieces.index_by(&:position)
  end

  private
end
