require "rails_helper"

RSpec.describe StretchStep, type: :model do
  describe "バリデーション" do
    it "有効なストレッチステップが作成できること" do
      stretch_step = build(:stretch_step)
      expect(stretch_step).to be_valid
    end

    it "step_numberが空の場合は無効であること" do
      stretch_step = build(:stretch_step, step_number: nil)
      expect(stretch_step).to be_invalid
    end

    it "image_pathが空の場合は無効であること" do
      stretch_step = build(:stretch_step, image_path: nil)
      expect(stretch_step).to be_invalid
    end

    it "descriptionが空の場合は無効であること" do
      stretch_step = build(:stretch_step, description: nil)
      expect(stretch_step).to be_invalid
    end

    it "同一stretch内でstep_numberが重複する場合は無効であること" do
      stretch = create(:stretch)
      create(:stretch_step, stretch: stretch, step_number: 1)
      duplicate = build(:stretch_step, stretch: stretch, step_number: 1)

      expect(duplicate).to be_invalid
    end

    it "異なるstretchであれば同じstep_numberでも有効であること" do
      stretch1 = create(:stretch)
      stretch2 = create(:stretch)
      create(:stretch_step, stretch: stretch1, step_number: 1)
      stretch_step = build(:stretch_step, stretch: stretch2, step_number: 1)

      expect(stretch_step).to be_valid
    end
  end

  describe "アソシエーション" do
    it "stretchに属すること" do
      stretch = create(:stretch)
      stretch_step = create(:stretch_step, stretch: stretch)

      expect(stretch_step.stretch).to eq(stretch)
    end
  end
end
