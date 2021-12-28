class AddConfirmedTempToReading < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_readings, :confirmed_tempf, :float
  end
end
