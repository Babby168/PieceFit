require "rails_helper"

RSpec.describe "shared/_google_analytics.html.erb", type: :view do
  it "指定した Measurement ID で gtag を埋め込むこと" do
    render partial: "shared/google_analytics", locals: { measurement_id: "G-TEST123" }

    expect(rendered).to inlcude("https://www.googletagmanager.com/gtag/js?id=G-TEST123")
    expect(rendered).to include("gtag('config', 'G-TEST123')")
    expect(rendered).to include("send_page_view: false")
  end
end
