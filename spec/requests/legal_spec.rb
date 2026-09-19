require "rails_helper"

RSpec.describe "Legal", type: :request do
  describe "GET /legal" do
    it "200ステータスを返すこと" do
      get legal_path
      expect(response).to have_http_status(:success)
    end

    it "プライバシーポリシーが表示されていること" do
      get legal_path
      expect(response.body).to include("プライバシーポリシー")
      expect(response.body).to include("制定日：2026年8月31日")
      expect(response.body).to include("改定日：2026年9月19日")
      expect(response.body).to include("Google Analytics")
      expect(response.body).to include("広告配信や第三者による解析を目的とした Cookie は使用しません")
    end

    it "利用規約が表示されていること" do
      get legal_path
      expect(response.body).to include("利用規約")
      expect(response.body).to include("制定日：2026年8月31日")
    end
  end
end
