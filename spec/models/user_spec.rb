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
