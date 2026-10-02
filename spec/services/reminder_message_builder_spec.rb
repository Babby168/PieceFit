require "rails_helper"

RSpec.describe ReminderMessageBuilder, type: :service do
  let!(:user) { create(:user) }
  let!(:stretch) { create(:stretch) }
  let!(:mosaic_design) { create(:mosaic_design, area_size_x: 4, area_size_y: 5) }
  let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

  describe "#call" do
    context "完成まで残り10ピース以下の場合" do
      before { create_pieces(total: 12, acquired: 10) }

      it "完成間近の文面を返すこと" do
        message = described_class.call(user)
        expect(message[:title]).to eq("完成まであと2ピース")
        expect(message[:body]).to be_present
      end
    end

    context "残りピースが多く、連続2日目の場合" do
      before do
        create_pieces(total: 20)
        create_log_on(1)
        create_log_on(0)
      end

      it "ボーナス予告の文面を返すこと" do
        message = described_class.call(user)
        expect(message[:title]).to eq("連続2日目！あと1日でボーナスピース")
      end
    end

    context "残りピースが多く、連続1日目の場合" do
      before do
        create_pieces(total: 20)
        create_log_on(0)
      end

      it "今日の残りピースの文面を返すこと" do
        message = described_class.call(user)
        expect(message[:title]).to eq("今日のピース、あと3つ獲得できます")
      end
    end

    context "今日すでに3ピース獲得している場合" do
      before { create_pieces(total: 20, acquired: 3, acquired_at: Time.current) }

      it "nil を返すこと（通知しない）" do
        expect(described_class.call(user)).to be_nil
      end
    end

    context "進行中のモザイクアートがない場合" do
      before do
        create_pieces(total: 20)
        mosaic_art.update!(completed_at: Time.current)
      end

      it "エラーにならず今日の残りピースの文面を返すこと" do
        message = described_class.call(user)
        expect(message[:title]).to eq("今日のピース、あと3つ獲得できます")
      end
    end
  end

  # total 個のピースを作り、先頭 acquired 個を獲得済みにする
  # 獲得日時を過去にしておかないと「今日の獲得数」に数えられてしまうので注意
  def create_pieces(total:, acquired: 0, acquired_at: 5.days.ago)
    total.times do |position|
      create(:piece,
             mosaic_art: mosaic_art,
             position: position,
             acquired_at: position < acquired ? acquired_at : nil)
    end
  end

  def create_log_on(days_ago)
    create(:stretch_log, user: user, stretch: stretch, performed_at: days_ago.days.ago)
  end
end
