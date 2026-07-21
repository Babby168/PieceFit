require "rails_helper"

RSpec.describe StretchesHelper, type: :helper do
  describe "#body_part_color" do
    it "首にはemeraldの背景色クラスを返すこと" do
      expect(helper.body_part_color("neck")).to eq("bg-emerald-200")
    end

    it "肩にはpurpleの背景色クラスを返すこと" do
      expect(helper.body_part_color("shoulder")).to eq("bg-purple-200")
    end

    it "腰にはyellowの背景色クラスを返すこと" do
      expect(helper.body_part_color("waist")).to eq("bg-yellow-200")
    end

    it "未定義の部位にはデフォルトの背景色クラスを返すこと" do
      expect(helper.body_part_color("unknown")).to eq("bg-base-100")
    end
  end
end
