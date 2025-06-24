require "test_helper"

class MistakeJournalControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mistake_journal_index_url
    assert_response :success
  end
end
