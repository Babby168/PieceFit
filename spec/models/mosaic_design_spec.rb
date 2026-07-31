require "rails_helper"

RSpec.describe MosaicDesign, type: :model do
  describe "バリデーション" do
    it "有効なモザイクデザインが作成できること" do
      mosaic_design = build(:mosaic_design)
      expect(mosaic_design).to be_valid
    end

    it "nameが空の場合は無効であること" do
      mosaic_design = build(:mosaic_design, name: nil)
      expect(mosaic_design).to be_invalid
    end

    it "nameが重複する場合は無効であること" do
      create(:mosaic_design, name: "ヒーロー01")
      mosaic_design = build(:mosaic_design, name: "ヒーロー01")
      expect(mosaic_design).to be_invalid
    end

    it "area_size_xが0以下の場合は無効であること" do
      mosaic_design = build(:mosaic_design, area_size_x: 0)
      expect(mosaic_design).to be_invalid
    end

    it "area_size_yが0以下の場合は無効であること" do
      mosaic_design = build(:mosaic_design, area_size_y: -1)
      expect(mosaic_design).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "design_piecesを複数持てること" do
      mosaic_design = create(:mosaic_design)
      design_piece = create(:design_piece, mosaic_design: mosaic_design)

      expect(mosaic_design.design_pieces).to include(design_piece)
    end

    it "削除時に関連するdesign_piecesも削除されること" do
      mosaic_design = create(:mosaic_design)
      create(:design_piece, mosaic_design: mosaic_design)

      expect { mosaic_design.destroy }.to change(DesignPiece, :count).by(-1)
    end
  end
end
