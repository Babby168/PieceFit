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

    it "住所が未設定でも有効であること" do
      expect(build(:mosaic_design, mosaic_series: nil, collection_position: nil)).to be_valid
    end

    it "in_collectionは住所が未設定の題材を含まないこと" do
      in_collection = create(:mosaic_design)
      without_address = create(:mosaic_design, mosaic_series: nil, collection_position: nil)
      expect(MosaicDesign.in_collection).to include(in_collection)
      expect(MosaicDesign.in_collection).not_to include(without_address)
    end

    it "同じシリーズでcollection_positionが重複する場合は無効であること" do
      series = create(:mosaic_series)
      create(:mosaic_design, mosaic_series: series, collection_position: 1)
      mosaic_design = build(:mosaic_design, mosaic_series: series, collection_position: 1)
      expect(mosaic_design).to be_invalid
    end

    it "別シリーズなら同じcollection_positionでも有効であること" do
      series1 = create(:mosaic_series)
      series2 = create(:mosaic_series, name: "別シリーズ")
      create(:mosaic_design, mosaic_series: series1, collection_position: 1)
      expect(build(:mosaic_design, mosaic_series: series2, collection_position: 1)).to be_valid
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

    it "mosaic_seriesに属すること" do
      series = create(:mosaic_series)
      mosaic_design = create(:mosaic_design, mosaic_series: series)
      expect(mosaic_design.mosaic_series).to eq(series)
    end
  end
end
