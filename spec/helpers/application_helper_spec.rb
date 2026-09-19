require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#google_analytics_measurement_id" do
    around do |example|
      original = ENV["GA_MEASUREMENT_ID"]
      example.run
      ENV["GA_MEASUREMENT_ID"] = original
    end

    context "本番環境のとき" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "Measurement IDがあればその値を返すこと" do
        ENV["GA_MEASUREMENT_ID"] = "G-TEST123"
        expect(helper.google_analytics_measurement_id).to eq("G-TEST123")
      end

      it "Measurement ID が空なら nil を返すこと" do
        ENV["GA_MEASUREMENT_ID"] = ""
        expect(helper.google_analytics_measurement_id).to be_nil
      end

      it "Measurement ID が未設定なら nil を返すこと" do
        ENV.delete("GA_MEASUREMENT_ID")
        expect(helper.google_analytics_measurement_id).to be_nil
      end
    end

    it "開発環境では ID があっても nil を返すこと" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      ENV["GA_MEASUREMENT_ID"] = "G-TEST123"
      expect(helper.google_analytics_measurement_id).to be_nil
    end

    it "テスト環境では ID があっても nil を返すこと" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
      ENV["GA_MEASUREMENT_ID"] = "G-TEST123"
      expect(helper.google_analytics_measurement_id).to be_nil
    end
  end
end
