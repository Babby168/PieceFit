require "rails_helper"

RSpec.describe MosaicArt, type: :model do
  describe "バリデーション" do
    it "有効なモザイクアートが作成できること" do
      mosaic_art = build(:mosaic_art)
      expect(mosaic_art).to be_valid
    end

    it "userが無い場合は無効であること" do
      mosaic_art = build(:mosaic_art, user: nil)
      expect(mosaic_art).to be_invalid
    end

    it "mosaic_designが無い場合は無効であること" do
      mosaic_art = build(:mosaic_art, mosaic_design: nil)
      expect(mosaic_art).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "userに属すること" do
      user = create(:user)
      mosaic_art = create(:mosaic_art, user: user)

      expect(mosaic_art.user).to eq(user)
    end

    it "mosaic_designに属すること" do
      mosaic_design = create(:mosaic_design)
      mosaic_art = create(:mosaic_art, mosaic_design: mosaic_design)

      expect(mosaic_art.mosaic_design).to eq(mosaic_design)
    end

    it "piecesを複数持てること" do
      mosaic_art = create(:mosaic_art)
      piece = create(:piece, mosaic_art: mosaic_art)

      expect(mosaic_art.pieces).to include(piece)
    end

    it "削除時に関連するpiecesも削除されること" do
      mosaic_art = create(:mosaic_art)
      create(:piece, mosaic_art: mosaic_art)

      expect { mosaic_art.destroy }.to change(Piece, :count).by(-1)
    end
  end
end
