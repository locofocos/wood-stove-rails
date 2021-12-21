class CreateTempMonitors < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_monitors do |t|
      t.float :upper_limitf
      t.float :lower_limitf

      t.timestamps
    end
  end
end
