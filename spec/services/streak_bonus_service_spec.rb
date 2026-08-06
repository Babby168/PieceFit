require "rails_helper"

RSpec.describe StreakBonusService, type: :service do
  let!(:user) { create(:user) }
  let!(:stretch) { create(:stretch) }
  let!(:mosaic_design) { create(:mosaic_design, area_size_x: 2, area_size_y: 2) }
  let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }
  let!(:piece_0) { create(:piece, mosaic_art: mosaic_art, position: 0) }
  let!(:piece_1) { create(:piece, mosaic_art: mosaic_art, position: 1) }
  let!(:piece_2) { create(:piece, mosaic_art: mosaic_art, position: 2) }
  let!(:piece_3) { create(:piece, mosaic_art: mosaic_art, position: 3) }

  describe "#call" do
    context "連続1日の場合" do
      before { create_log_on(0) }

      it ":not_eligible を返しピースを付与しないこと" do
        expect {
          result = described_class.call(user)
          expect(result.status).to eq(:not_eligible)
          expect(result.streak_days).to eq(1)
        }.not_to change { mosaic_art.pieces.acquired.count }
      end
    end

    context "連続2日の場合" do
      before do
        create_log_on(1)
        create_log_on(0)
      end

      it ":not_eligible を返すこと" do
        result = described_class.call(user)
        expect(result.status).to eq(:not_eligible)
        expect(result.streak_days).to eq(2)
      end
    end

    context "連続3日の場合" do
      before do
        create_log_on(2)
        create_log_on(1)
        create_log_on(0)
      end

      it "ボーナスピースを1つ付与すること" do
        result = described_class.call(user)

        expect(result.status).to eq(:awarded)
        expect(result.streak_days).to eq(3)
        expect(result.piece).to eq(piece_0)
        expect(piece_0.reload).to have_attributes(is_bonus: true)
        expect(piece_0.acquired_at).to be_present
      end

      it "同日2回目は :already_awarded を返すこと" do
        described_class.call(user)

        expect {
          result = described_class.call(user)
          expect(result.status).to eq(:already_awarded)
        }.not_to change { mosaic_art.pieces.acquired.count }
      end
    end

    context "連続6日の場合" do
      before do
        # ３日目相当のボーナスは「昨日付与済み」想定
        create_log_on(5)
        create_log_on(4)
        create_log_on(3)
        create_log_on(2)
        create_log_on(1)
        create_log_on(0)
        piece_0.update!(acquired_at: 3.days.ago, is_bonus: true)
      end

      it "6日目でも再度ボーナスピースを付与すること" do
        result = described_class.call(user)

        expect(result.status).to eq(:awarded)
        expect(result.streak_days).to eq(6)
        expect(piece_1.reload.is_bonus).to be true
      end
    end

    context "途中で1日欠けている場合" do
      before do
        create_log_on(2) # 一昨日
        # 昨日はなし
        create_log_on(0) # 今日
      end

      it "連続が切れ :not_eligible になること" do
        result = described_class.call(user)
        expect(result.status).to eq(:not_eligible)
        expect(result.streak_days).to eq(1)
      end
    end

    context "通常ピースが日次上限に達している場合" do
      before do
        create_log_on(2)
        create_log_on(1)
        create_log_on(0)
        piece_0.update!(acquired_at: Time.current, is_bonus: false)
        piece_1.update!(acquired_at: Time.current, is_bonus: false)
        piece_2.update!(acquired_at: Time.current, is_bonus: false)
      end

      it "ボーナスは日次上限の対象外で付与されること" do
        result = described_class.call(user)

        expect(result.status).to eq(:awarded)
        expect(piece_3.reload.is_bonus).to be true
      end
    end

    context "進行中アートのピースが全て獲得済みの場合" do
      before do
        create_log_on(2)
        create_log_on(1)
        create_log_on(0)
        mosaic_art.pieces.update_all(acquired_at: 1.day.ago)
      end

      it ":already_completed を返すこと" do
        result = described_class.call(user)
        expect(result.status).to eq(:already_completed)
      end
    end

    context "MosaicDesignが存在しない場合" do
      before do
        create_log_on(2)
        create_log_on(1)
        create_log_on(0)
        mosaic_art.destroy!
        MosaicDesign.destroy_all
      end

      it ":no_design を返すこと" do
        result = described_class.call(user)
        expect(result.status).to eq(:no_design)
      end
    end
  end

  def create_log_on(days_ago)
    create(:stretch_log, user: user, stretch: stretch, performed_at: days_ago.days.ago)
  end
end
