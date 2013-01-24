require 'test_helper'

class PidControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
