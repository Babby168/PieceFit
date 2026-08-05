module MosaicGridAssignable
  extend ActiveSupport::Concern

  private

  def assign_mosaic_grid!(user)
    @mosaic_art = PieceAcquisitionService.new(user).ensure_current_mosaic_art!
    return unless @mosaic_art

    @mosaic_design = @mosaic_art.mosaic_design
    @design_pieces_by_position = @mosaic_design.design_pieces.index_by(&:position)
    @pieces_by_position = @mosaic_art.pieces.index_by(&:position)
  end
end
