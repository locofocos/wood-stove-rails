require "test_helper"

class TempMonitorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @temp_monitor = temp_monitors(:one)
  end

  test "should get index" do
    get temp_monitors_url
    assert_response :success
  end

  test "should get new" do
    get new_temp_monitor_url
    assert_response :success
  end

  test "should create temp_monitor" do
    assert_difference("TempMonitor.count") do
      post temp_monitors_url, params: { temp_monitor: { lower_limitf: @temp_monitor.lower_limitf, upper_limitf: @temp_monitor.upper_limitf } }
    end

    assert_redirected_to temp_monitor_url(TempMonitor.last)
  end

  test "should show temp_monitor" do
    get temp_monitor_url(@temp_monitor)
    assert_response :success
  end

  test "should get edit" do
    get edit_temp_monitor_url(@temp_monitor)
    assert_response :success
  end

  test "should update temp_monitor" do
    patch temp_monitor_url(@temp_monitor), params: { temp_monitor: { lower_limitf: @temp_monitor.lower_limitf, upper_limitf: @temp_monitor.upper_limitf } }
    assert_redirected_to temp_monitor_url(@temp_monitor)
  end

  test "should destroy temp_monitor" do
    assert_difference("TempMonitor.count", -1) do
      delete temp_monitor_url(@temp_monitor)
    end

    assert_redirected_to temp_monitors_url
  end
end
