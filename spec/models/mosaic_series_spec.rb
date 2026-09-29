require "rails_helper"

RSpec.describe MosaicSeries, type: :model do
  describe "バリデーション" do
    it "有効なシリーズが作成できること" do
      expect(build(:mosaic_series)).to be_valid
    end

    it "nameが空の場合は無効であること" do
      expect(build(:mosaic_series, name: nil)).to be_invalid
    end

    it "nameが重複する場合は無効であること" do
      create(:mosaic_series, name: "おじさんシリーズ")
      expect(build(:mosaic_series, name: "おじさんシリーズ")).to be_invalid
    end

    it "positionが重複する場合は無効であること" do
      create(:mosaic_series, position: 1)
      expect(build(:mosaic_series, position: 1)).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "題材が残っているシリーズは削除できないこと" do
      series = create(:mosaic_series)
      create(:mosaic_design, mosaic_series: series)

      expect(series.destroy).to be false
      expect(series.errors).to be_of_kind(:base, :"restrict_dependent_destroy.has_many")
    end
  end
end
