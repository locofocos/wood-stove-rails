class AddRawTempToReadings < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_readings, :raw_tempf, :float
  end
end
