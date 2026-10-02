class RemindersController < ApplicationController
  def show
    # 未ログインなら何も返さない（JS側は 204 を「通知しない」と解釈する）
    return head :no_content unless user_signed_in?

    message = ReminderMessageBuilder.call(current_user)
    return head :no_content if message.nil?

    render json: message
  end
end
