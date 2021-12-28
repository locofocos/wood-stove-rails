class FixColumnTypes < ActiveRecord::Migration[7.0]
  def change
    drop_table :settings

    create_table :settings do |t|
      t.float :static_temp_factor
      t.float :dynamic_temp_factor

      t.timestamps
    end
  end
end
