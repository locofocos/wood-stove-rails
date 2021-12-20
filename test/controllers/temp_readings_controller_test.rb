require "test_helper"

class TempReadingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get temp_readings_index_url
    assert_response :success
  end
end
