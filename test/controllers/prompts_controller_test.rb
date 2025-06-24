require "test_helper"

class PromptsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prompts_index_url
    assert_response :success
  end

  test "should get show" do
    get prompts_show_url
    assert_response :success
  end
end
