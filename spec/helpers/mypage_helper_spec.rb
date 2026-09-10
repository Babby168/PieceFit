require "rails_helper"

RSpec.describe MypageHelper, type: :helper do
  describe "#body_part_bar_width_percent" do
    it "最大回数が0のときは0を返すこと" do
      expect(helper.body_part_bar_width_percent(0, 0)).to eq(0)
    end

    it "いちばん多い部位は100になること" do
      expect(helper.body_part_bar_width_percent(10, 10)).to eq(100)
    end

    it "回数の割合をパーセントにすること" do
      expect(helper.body_part_bar_width_percent(5, 10)).to eq(50)
    end

    it "1回以上なら最低8パーセントになること" do
      expect(helper.body_part_bar_width_percent(1, 100)).to eq(8)
    end

    it "0回なら0パーセントのままであること" do
      expect(helper.body_part_bar_width_percent(0, 10)).to eq(0)
    end
  end

  describe "#least_active_body_part_message" do
    it "記録がないときは文言を出さないこと" do
      counts = { "neck" => 0, "shoulder" => 0, "waist" => 0 }
      expect(helper.least_active_body_part_message(counts)).to be_nil
    end

    it "単独で最少の部位を日本語と回数で返すこと" do
      counts = { "neck" => 5, "shoulder" => 2, "waist" => 0 }
      expect(helper.least_active_body_part_message(counts)).to eq("いちばん少ない部位は腰です (0回)")
    end

    it "2部位以上が同率最少のときは同じ回数である旨を返すこと" do
      counts = { "neck" => 3, "shoulder" => 1, "waist" => 1 }
      expect(helper.least_active_body_part_message(counts)).to eq("複数の部位が同じ回数です")
    end

    it "3部位とも同じ回数(1回以上)のときも同率文言であること" do
      counts = { "neck" => 2, "shoulder" => 2, "waist" => 2 }
      expect(helper.least_active_body_part_message(counts)).to eq("複数の部位が同じ回数です")
    end
  end
end
