require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "reset_instructions" do
    let(:user) { create(:user) }
    let(:raw_token) { "sample_raw_token" }
    let(:mail) { PasswordResetMailer.reset_instructions(user, raw_token) }

    it "登録メールアドレス宛に送信されること" do
      expect(mail.to).to eq([ user.email ])
    end

    it "件名が正しいこと" do
      expect(mail.subject).to eq("【PieceFit】パスワード再設定の確認")
    end

    it "本文に再設定用URLが含まれること" do
      expected_url = Rails.application.routes.url_helpers.password_reset_confirm_url(token: raw_token, host: "example.com")
      expect(mail.body.encoded).to include(expected_url)
    end

    it "本文にユーザーのニックネームが含まれること" do
      expect(mail.body.encoded).to include(user.nickname)
    end
  end
end
