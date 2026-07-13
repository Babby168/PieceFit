require "test_helper"

class RegistrationCompleteControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get registration_complete_show_url
    assert_response :success
  end
end
