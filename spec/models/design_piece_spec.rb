require "rails_helper"

RSpec.describe DesignPiece, type: :model do
  describe "バリデーション" do
    it "有効なデザインピースが作成できること" do
      design_piece = build(:design_piece)
      expect(design_piece).to be_valid
    end

    it "positionが空の場合は無効であること" do
      design_piece = build(:design_piece, position: nil)
      expect(design_piece).to be_invalid
    end

    it "positionが負の場合は無効であること" do
      design_piece = build(:design_piece, position: -1)
      expect(design_piece).to be_invalid
    end

    it "同じmosaic_design内でpositionが重複する場合は無効であること" do
      mosaic_design = create(:mosaic_design)
      create(:design_piece, mosaic_design: mosaic_design, position: 0)
      design_piece = build(:design_piece, mosaic_design: mosaic_design, position: 0)
      expect(design_piece).to be_invalid
    end

    it "colorが空の場合は無効であること" do
      design_piece = build(:design_piece, color: [])
      expect(design_piece).to be_invalid
    end

    it "colorが4色でない場合は無効であること" do
      design_piece = build(:design_piece, color: [ "#FFFFFF", "#000000" ])
      expect(design_piece).to be_invalid
      expect(design_piece.errors[:color]).to include("は4色（左上・右上・左下・右下）である必要があります")
    end

    it "colorがHEX形式でない場合は無効であること" do
      design_piece = build(:design_piece, color: [ "red", "#000000", "#111111", "#222222" ])
      expect(design_piece).to be_invalid
      expect(design_piece.errors[:color]).to include("はHEXカラーコード形式である必要があります")
    end
  end

  describe "アソシエーション" do
    it "mosaic_designに属すること" do
      mosaic_design = create(:mosaic_design)
      design_piece = create(:design_piece, mosaic_design: mosaic_design)

      expect(design_piece.mosaic_design).to eq(mosaic_design)
    end
  end
end
