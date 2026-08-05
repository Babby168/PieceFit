require "rails_helper"

RSpec.describe PieceAcquisitionService, type: :service do
  let(:user) { create(:user) }
  let!(:mosaic_design) { create(:mosaic_design, area_size_x: 2, area_size_y: 2) }

  before do
    4.times { |i| create(:design_piece, mosaic_design: mosaic_design, position: i) }
  end

  describe ".call" do
    context "進行中のMosaicArtがある場合" do
      let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }
      let!(:piece_0) { create(:piece, mosaic_art: mosaic_art, position: 0) }
      let!(:piece_1) { create(:piece, mosaic_art: mosaic_art, position: 1) }
      let!(:piece_2) { create(:piece, mosaic_art: mosaic_art, position: 2) }
      let!(:piece_3) { create(:piece, mosaic_art: mosaic_art, position: 3) }

      it "未獲得の最小positionのピースを獲得すること" do
        result = described_class.call(user)

        expect(result.status).to eq(:acquired)
        expect(result.piece).to eq(piece_0)
        expect(piece_0.reload.acquired_at).to be_present
        expect(piece_1.reload.acquired_at).to be_nil
      end

      it "2回目は次のpositionを獲得すること" do
        described_class.call(user)
        result = described_class.call(user)

        expect(result.status).to eq(:acquired)
        expect(result.piece).to eq(piece_1)
        expect(piece_1.reload.acquired_at).to be_present
      end

      it "1日3件を超えると獲得せず :daily_limit を返すこと" do
        3.times { described_class.call(user) }

        expect {
          result = described_class.call(user)
          expect(result.status).to eq(:daily_limit)
          expect(result.piece).to be_nil
        }.not_to change { mosaic_art.pieces.acquired.count }
      end

      it "昨日獲得した分は本日の上限に含まないこと" do
        piece_0.update!(acquired_at: 1.day.ago)
        piece_1.update!(acquired_at: 1.day.ago)
        piece_2.update!(acquired_at: 1.day.ago)

        result = described_class.call(user)

        expect(result.status).to eq(:acquired)
        expect(piece_3.reload.acquired_at).to be_present
      end

      it "最後のピース獲得時に completed_at が設定されること" do
        piece_0.update!(acquired_at: 1.day.ago)
        piece_1.update!(acquired_at: 1.day.ago)
        piece_2.update!(acquired_at: 1.day.ago)

        result = described_class.call(user)

        expect(result.status).to eq(:acquired)
        expect(piece_3.reload.acquired_at).to be_present
        expect(mosaic_art.reload.completed_at).to be_present
      end
    end

    context "進行中アートのピースがすべて獲得済みの場合" do
      let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

      before do
        4.times do |i|
          create(:piece, mosaic_art: mosaic_art, position: i, acquired_at: 1.day.ago)
        end
      end

      it ":already_completed を返し獲得数が増えないこと" do
        expect {
          result = described_class.call(user)
          expect(result.status).to eq(:already_completed)
        }.not_to change { mosaic_art.pieces.acquired.count }
      end
    end

    context "MosaicArtが未作成の場合" do
      it "MosaicArtとPieceを自動作成してから獲得すること" do
        expect {
          result = described_class.call(user)
          expect(result.status).to eq(:acquired)
        }.to change(MosaicArt, :count).by(1)
         .and change(Piece, :count).by(4)

        mosaic_art = user.mosaic_arts.last
        expect(mosaic_art.pieces.acquired.count).to eq(1)
        expect(mosaic_art.pieces.unacquired.count).to eq(3)
      end
    end

    context "MosaicDesignが存在しない場合" do
      before { MosaicDesign.destroy_all }

      it ":no_design を返すこと" do
        result = described_class.call(user)

        expect(result.status).to eq(:no_design)
        expect(result.piece).to be_nil
        expect(MosaicArt.count).to eq(0)
      end
    end
  end

  describe "#ensure_current_mosaic_art!" do
    it "進行中のアートがあればそれを返すこと" do
      mosaic_art = create(:mosaic_art, user: user, mosaic_design: mosaic_design)

      expect(described_class.new(user).ensure_current_mosaic_art!).to eq(mosaic_art)
    end

    it "無ければ作成して返すこと" do
      expect {
        art = described_class.new(user).ensure_current_mosaic_art!
        expect(art).to be_a(MosaicArt)
        expect(art.pieces.count).to eq(4)
      }.to change(MosaicArt, :count).by(1)
    end
  end
end
