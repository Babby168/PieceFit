require "rails_helper"

RSpec.describe EmailChangeMailer, type: :mailer do
  describe "confirmation_instructions" do
    let(:user) do
      create(:user, unconfirmed_email: "new@example.com",
                    email_change_token: "sample_token",
                    email_change_token_sent_at: Time.current)
    end
    let(:mail) { EmailChangeMailer.confirmation_instructions(user) }

    it "新しいメールアドレス宛に送信されること" do
      expect(mail.to).to eq(["new@example.com"])
    end

    it "件名が正しいこと" do
      expect(mail.subject).to eq("【PieceFit】メールアドレス変更の確認")
    end

    it "本文に確認用URLが含まれること" do
      expected_url = Rails.application.routes.url_helpers
                        .email_change_confirm_url(token: user.email_change_token,
                                                  host: "example.com")
      expect(mail.body.encoded).to include(expected_url)
    end

    it "本文にユーザーのニックネームが含まれること" do
      expect(mail.body.encoded).to include(user.nickname)
    end
  end
end
