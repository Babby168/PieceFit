class StretchLogsController < ApplicationController
  include MosaicGridAssignable

  def create
    return head :no_content unless user_signed_in?

    @stretch_log = current_user.stretch_logs.build(stretch_log_params)
    @stretch_log.performed_at = Time.current

    if @stretch_log.save
      PieceAcquisitionService.call(current_user)
      assign_mosaic_grid!(current_user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to mypage_path }
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def stretch_log_params
    params.permit(:stretch_id)
  end
end
