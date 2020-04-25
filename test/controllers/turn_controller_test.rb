require 'test_helper'

class TurnControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get turn_show_url
    assert_response :success
  end

end
