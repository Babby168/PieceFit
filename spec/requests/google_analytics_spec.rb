require "rails_helper"

RSpec.describe "Google Analytics", type: :request do
  it "テスト環境では gtag を埋め込めないこと" do
    ENV["GA_MEASUREMENT_ID"] = "G-TEST123"
    get root_path

    expect(response.body).not_to include("googletagmanager.com/gtag/js")
    expect(response.body).not_to include("gtag(")
  end
end
