class CreateTempReadings < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_readings do |t|
      t.float :tempf

      t.timestamps
    end
  end
end
