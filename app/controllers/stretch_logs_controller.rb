class StretchLogsController < ApplicationController
  def create
    return head :no_content unless user_signed_in?

    @stretch_log = current_user.stretch_logs.build(stretch_log_params)
    @stretch_log.performed_at = Time.current

    if @stretch_log.save
      PieceAcquisitionService.call(current_user)
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

  def stretch_log_params
    params.permit(:stretch_id)
  end
end
