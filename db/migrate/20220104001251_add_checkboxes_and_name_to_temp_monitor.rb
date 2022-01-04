class AddCheckboxesAndNameToTempMonitor < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_monitors, :title, :string
    add_column :temp_monitors, :send_notifications, :boolean
    add_column :temp_monitors, :toggle_fan, :boolean
    add_column :temp_monitors, :enabled, :boolean
  end
end
