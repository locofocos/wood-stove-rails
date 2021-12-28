require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @settings = settings(:one)
  end

  test "should get index" do
    get settings_index_url
    assert_response :success
  end

  test "should get new" do
    get new_settings_url
    assert_response :success
  end

  test "should create settings" do
    assert_difference("Settings.count") do
      post settings_index_url, params: { settings: { dynamic_temp_factor: @settings.dynamic_temp_factor, static_temp_factor: @settings.static_temp_factor } }
    end

    assert_redirected_to settings_url(Settings.last)
  end

  test "should show settings" do
    get settings_url(@settings)
    assert_response :success
  end

  test "should get edit" do
    get edit_settings_url(@settings)
    assert_response :success
  end

  test "should update settings" do
    patch settings_url(@settings), params: { settings: { dynamic_temp_factor: @settings.dynamic_temp_factor, static_temp_factor: @settings.static_temp_factor } }
    assert_redirected_to settings_url(@settings)
  end

  test "should destroy settings" do
    assert_difference("Settings.count", -1) do
      delete settings_url(@settings)
    end

    assert_redirected_to settings_index_url
  end
end
