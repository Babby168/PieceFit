require "rails_helper"

RSpec.describe StretchLog, type: :model do
  describe "バリデーション" do
    it "有効なストレッチ実施記録が作成できること" do
      stretch_log = build(:stretch_log)
      expect(stretch_log).to be_valid
    end

    it "performed_atが空の場合は無効であること" do
      stretch_log = build(:stretch_log, performed_at: nil)
      expect(stretch_log).to be_invalid
    end

    it "userが空の場合は無効であること" do
      stretch_log = build(:stretch_log, user: nil)
      expect(stretch_log).to be_invalid
    end

    it "stretchが空の場合は無効であること" do
      stretch_log = build(:stretch_log, stretch: nil)
      expect(stretch_log).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "userに属すること" do
      user = create(:user)
      stretch_log = create(:stretch_log, user: user)

      expect(stretch_log.user).to eq(user)
    end

    it "stretchに属すること" do
      stretch = create(:stretch)
      stretch_log = create(:stretch_log, stretch: stretch)

      expect(stretch_log.stretch).to eq(stretch)
    end
  end
end
