require "application_system_test_case"

class TempMonitorsTest < ApplicationSystemTestCase
  setup do
    @temp_monitor = temp_monitors(:one)
  end

  test "visiting the index" do
    visit temp_monitors_url
    assert_selector "h1", text: "Temp monitors"
  end

  test "should create temp monitor" do
    visit temp_monitors_url
    click_on "New temp monitor"

    fill_in "Lower limitf", with: @temp_monitor.lower_limitf
    fill_in "Upper limitf", with: @temp_monitor.upper_limitf
    click_on "Create Temp monitor"

    assert_text "Temp monitor was successfully created"
    click_on "Back"
  end

  test "should update Temp monitor" do
    visit temp_monitor_url(@temp_monitor)
    click_on "Edit this temp monitor", match: :first

    fill_in "Lower limitf", with: @temp_monitor.lower_limitf
    fill_in "Upper limitf", with: @temp_monitor.upper_limitf
    click_on "Update Temp monitor"

    assert_text "Temp monitor was successfully updated"
    click_on "Back"
  end

  test "should destroy Temp monitor" do
    visit temp_monitor_url(@temp_monitor)
    click_on "Destroy this temp monitor", match: :first

    assert_text "Temp monitor was successfully destroyed"
  end
end
