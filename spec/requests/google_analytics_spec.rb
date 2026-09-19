require "rails_helper"

RSpec.describe "Google Analytics", type: :request do
  around do |example|
    original = ENV["GA_MEASUREMENT_ID"]
    example.run
    ENV["GA_MEASUREMENT_ID"] = original
  end

  it "テスト環境では gtag を埋め込めないこと" do
    ENV["GA_MEASUREMENT_ID"] = "G-TEST123"
    get root_path

    expect(response.body).not_to include("googletagmanager.com/gtag/js")
    expect(response.body).not_to include("gtag(")
  end
end
