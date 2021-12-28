require "application_system_test_case"

class SettingsTest < ApplicationSystemTestCase
  setup do
    @settings = settings(:one)
  end

  test "visiting the index" do
    visit settings_url
    assert_selector "h1", text: "Settings"
  end

  test "should create settings" do
    visit settings_url
    click_on "New settings"

    fill_in "Dynamic temp factor", with: @settings.dynamic_temp_factor
    fill_in "Static temp factor", with: @settings.static_temp_factor
    click_on "Create Settings"

    assert_text "Settings was successfully created"
    click_on "Back"
  end

  test "should update Settings" do
    visit settings_url(@settings)
    click_on "Edit this settings", match: :first

    fill_in "Dynamic temp factor", with: @settings.dynamic_temp_factor
    fill_in "Static temp factor", with: @settings.static_temp_factor
    click_on "Update Settings"

    assert_text "Settings was successfully updated"
    click_on "Back"
  end

  test "should destroy Settings" do
    visit settings_url(@settings)
    click_on "Destroy this settings", match: :first

    assert_text "Settings was successfully destroyed"
  end
end
