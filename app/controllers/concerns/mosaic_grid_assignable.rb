module MosaicGridAssignable
  extend ActiveSupport::Concern

  private

  # モザイクグリッドを割り当てる
  def assign_mosaic_grid!(user)
    # 進行中のモザイクアートがあればそれを取得
    @mosaic_art = user.mosaic_arts.in_progress.order(:created_at).last
    # なければ直近の完了したモザイクアートを取得
    @mosaic_art ||= user.mosaic_arts.where.not(completed_at: nil).order(completed_at: :desc).last
    # なければ新規モザイクアートを作成
    @mosaic_art ||= PieceAcquisitionService.new(user).ensure_current_mosaic_art!
    # モザイクアートが存在しない場合は終了
    return unless @mosaic_art


    # モザイクデザインを取得
    @mosaic_design = @mosaic_art.mosaic_design
    # デザインピースを取得
    @design_pieces_by_position = @mosaic_design.design_pieces.index_by(&:position)
    # モザイクアートのピースを取得
    @pieces_by_position = @mosaic_art.pieces.index_by(&:position)
  end
end
