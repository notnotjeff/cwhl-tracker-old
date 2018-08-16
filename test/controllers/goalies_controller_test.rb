require 'test_helper'

class GoaliesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get goalies_index_url
    assert_response :success
  end

  test "should get show" do
    get goalies_show_url
    assert_response :success
  end

end
