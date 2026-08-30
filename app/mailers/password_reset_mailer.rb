class PasswordResetMailer < ApplicationMailer
  def reset_instructions(user, raw_token)
    @user = user
    @confirm_url = password_reset_confirm_url(token: raw_token)
    mail to: user.email, subject: "【PieceFit】パスワード再設定の確認"
  end
end
