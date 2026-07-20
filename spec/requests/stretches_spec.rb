require 'rails_helper'

RSpec.describe "Stretches", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/stretches/index"
      expect(response).to have_http_status(:success)
    end
  end

end
