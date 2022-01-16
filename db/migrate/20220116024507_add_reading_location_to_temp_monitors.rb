class AddReadingLocationToTempMonitors < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_monitors, :reading_location, :string

    TempMonitor.update_all(reading_location: 'INTERNAL_TEMPF')
  end
end
