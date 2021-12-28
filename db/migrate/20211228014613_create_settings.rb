class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.integer :static_temp_factor
      t.integer :dynamic_temp_factor

      t.timestamps
    end
  end
end
