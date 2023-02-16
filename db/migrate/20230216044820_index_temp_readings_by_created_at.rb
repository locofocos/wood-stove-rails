class IndexTempReadingsByCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index :temp_readings, :created_at
  end
end
