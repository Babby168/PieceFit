class EmailChangeMailer < ApplicationMailer
  def confirmation_instructions(user)
    @user = user
    @confirm_url = email_change_confirm_url(token: user.email_change_token)
    mail to: user.unconfirmed_email, subject: "【PieceFit】メールアドレス変更の確認"
  end
end
