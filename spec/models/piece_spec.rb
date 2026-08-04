require "rails_helper"

RSpec.describe Piece, type: :model do
  describe "バリデーション" do
    it "有効なピースが作成できること" do
      piece = build(:piece)
      expect(piece).to be_valid
    end

    it "positionが空の場合は無効であること" do
      piece = build(:piece, position: nil)
      expect(piece).to be_invalid
    end

    it "positionが負の場合は無効であること" do
      piece = build(:piece, position: -1)
      expect(piece).to be_invalid
    end

    it "同じmosaic_art内でpositionが重複する場合は無効であること" do
      mosaic_art = create(:mosaic_art)
      create(:piece, mosaic_art: mosaic_art, position: 0)
      piece = build(:piece, mosaic_art: mosaic_art, position: 0)

      expect(piece).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "mosaic_artに属すること" do
      mosaic_art = create(:mosaic_art)
      piece = create(:piece, mosaic_art: mosaic_art)

      expect(piece.mosaic_art).to eq(mosaic_art)
    end
  end
end
