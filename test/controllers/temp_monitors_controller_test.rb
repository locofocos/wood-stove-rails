require "test_helper"

class TempMonitorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get temp_monitors_index_url
    assert_response :success
  end

  test "should get show" do
    get temp_monitors_show_url
    assert_response :success
  end

  test "should get edit" do
    get temp_monitors_edit_url
    assert_response :success
  end

  test "should get update" do
    get temp_monitors_update_url
    assert_response :success
  end
end
