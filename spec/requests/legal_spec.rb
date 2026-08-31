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
    end

    it "利用規約が表示されていること" do
      get legal_path
      expect(response.body).to include("利用規約")
      expect(response.body).to include("制定日：2026年8月31日")
    end
  end
end
