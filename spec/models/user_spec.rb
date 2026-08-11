require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "有効なユーザーが作成できること" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "nicknameが空の場合は無効であること" do
      user = build(:user, nickname: nil)
      expect(user).to be_invalid
    end

    it "emailが空の場合は無効であること" do
      user = build(:user, email: nil)
      expect(user).to be_invalid
    end

    it "passwordが空の場合は無効であること" do
      user = build(:user, password: nil)
      expect(user).to be_invalid
    end

    it "passwordが6文字未満の場合は無効であること" do
      user = build(:user, password: Faker::Internet.password(min_length: 3, max_length: 5))
      expect(user).to be_invalid
    end

    it "password_confirmationが空の場合は無効であること" do
      user = build(:user, password_confirmation: nil)
      expect(user).to be_invalid
    end

    it "passwordとpassword_confirmationが一致しない場合は無効であること" do
      user = build(:user, password: Faker::Internet.password(min_length: 6), password_confirmation: Faker::Internet.password(min_length: 6))
      expect(user).to be_invalid
    end

    it "emailがすでに存在する場合は無効であること" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).to be_invalid
    end

    it "nicknameがすでに存在する場合は無効であること" do
      create(:user, nickname: "test")
      user = build(:user, nickname: "test")
      expect(user).to be_invalid
    end

    it "nickname が10文字を超える場合は無効であること" do
      user = build(:user, nickname: Faker::Lorem.characters(number: 11))
      expect(user).to be_invalid
    end

    it "nickname が10文字以内の場合は有効であること" do
      user = build(:user, nickname: Faker::Lorem.characters(number: 10))
      expect(user).to be_valid
    end
  end

  describe "メールアドレス変更バリデーション" do
    let(:user) { create(:user) }

    it "unconfirmed_email が空の場合は無効であること" do
      user.unconfirmed_email = ""
      expect(user.valid?(:email_change)).to be false
    end

    it "unconfirmed_email の形式が不正な場合は無効であること" do
      user.unconfirmed_email = "invalid_email"
      expect(user.valid?(:email_change)).to be false
    end

    it "unconfirmed_email が現在のemailと同じ場合は無効であること" do
      user.unconfirmed_email = user.email
      expect(user.valid?(:email_change)).to be false
    end

    it "unconfirmed_email が他のユーザーのemailと重複する場合は無効であること" do
      create(:user, email: "duplicate@example.com")
      user.unconfirmed_email = "duplicate@example.com"
      expect(user.valid?(:email_change)).to be false
    end

    it "有効な新しいメールアドレスの場合は有効であること" do
      user.unconfirmed_email = "new-email@example.com"
      expect(user.valid?(:email_change)).to be true
    end

    it "通常のバリデーション（コンテキスト指定なし）ではunconfirmed_emailは検証されないこと" do
      user.unconfirmed_email = nil
      expect(user).to be_valid
    end
  end

  describe "#generate_email_change_token!" do
    let(:user) { create(:user, unconfirmed_email: "new-email@example.com") }

    it "unconfirmed_email・email_change_token・email_change_token_sent_atが保存されること" do
      expect { user.generate_email_change_token! }
        .to change { user.reload.email_change_token }.from(nil)
      expect(user.email_change_token_sent_at).to be_present
    end
  end

  describe "#email_change_token_expired?" do
    let(:user) { create(:user) }

    it "email_change_token_sent_atがnilの場合はtrueを返すこと" do
      expect(user.email_change_token_expired?).to be true
    end

    it "24時間以内の場合はfalseを返すこと" do
      user.update!(email_change_token_sent_at: 23.hours.ago)
      expect(user.email_change_token_expired?).to be false
    end

    it "24時間以上経過した場合はtrueを返すこと" do
      user.update!(email_change_token_sent_at: 25.hours.ago)
      expect(user.email_change_token_expired?).to be true
    end
  end

  describe "#confirm_email_change!" do
    let(:user) do
      create(:user, unconfirmed_email: "new-email@example.com",
                    email_change_token: "token",
                    email_change_token_sent_at: Time.current)
    end

    it "emailがunconfirmed_emailの値に更新されること" do
      expect { user.confirm_email_change! }
      .to change { user.reload.email }.to("new-email@example.com")
    end

    it "unconfirmed_email・email_change_token・email_change_token_sent_atがクリアされること" do
      user.confirm_email_change!
      user.reload
      expect(user.unconfirmed_email).to be_nil
      expect(user.email_change_token).to be_nil
      expect(user.email_change_token_sent_at).to be_nil
    end
  end

  describe "アソシエーション" do
    it "stretch_logsを複数持てること" do
      user = create(:user)
      stretch_log = create(:stretch_log, user: user)

      expect(user.stretch_logs).to include(stretch_log)
    end

    it "user削除時に関連するstretch_logsも削除されること" do
      user = create(:user)
      create(:stretch_log, user: user)

      expect { user.destroy }.to change(StretchLog, :count).by(-1)
    end
  end
end
