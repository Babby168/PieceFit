require "rails_helper"

RSpec.describe Stretch, type: :model do
  describe "バリデーション" do
    it "有効なストレッチが作成できること" do
      stretch = build(:stretch)
      expect(stretch).to be_valid
    end

    it "nameが空の場合は無効であること" do
      stretch = build(:stretch, name: nil)
      expect(stretch).to be_invalid
    end

    it "body_partが空の場合は無効であること" do
      stretch = build(:stretch, body_part: nil)
      expect(stretch).to be_invalid
    end
  end

  describe "enum" do
    it "body_partにneck, shoulder, waistを設定できること" do
      expect(build(:stretch, body_part: :neck)).to be_valid
      expect(build(:stretch, :shoulder)).to be_valid
      expect(build(:stretch, :waist)).to be_valid
    end
  end

  describe "アソシエーション" do
    it "stretch_stepsを複数持てること" do
      stretch = create(:stretch)
      step = create(:stretch_step, stretch: stretch)

      expect(stretch.stretch_steps).to include(step)
    end

    it "stretch_stepsがstep_numberの昇順で取得できること" do
      stretch = create(:stretch)
      step3 = create(:stretch_step, stretch: stretch, step_number: 3)
      step1 = create(:stretch_step, stretch: stretch, step_number: 1)
      step2 = create(:stretch_step, stretch: stretch, step_number: 2)

      expect(stretch.stretch_steps).to eq([ step1, step2, step3 ])
    end

    it "stretch削除時に関連するstretch_stepsも削除されること" do
      stretch = create(:stretch)
      create(:stretch_step, stretch: stretch)

      expect { stretch.destroy }.to change(StretchStep, :count).by(-1)
    end
  end
end
