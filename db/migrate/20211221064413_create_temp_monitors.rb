class CreateTempMonitors < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_monitors do |t|

      t.timestamps
    end
  end
end
