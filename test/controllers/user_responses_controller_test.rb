require "test_helper"

class UserResponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get user_responses_new_url
    assert_response :success
  end

  test "should get create" do
    get user_responses_create_url
    assert_response :success
  end

  test "should get show" do
    get user_responses_show_url
    assert_response :success
  end

  test "should get index" do
    get user_responses_index_url
    assert_response :success
  end
end
