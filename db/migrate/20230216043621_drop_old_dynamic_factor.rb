class DropOldDynamicFactor < ActiveRecord::Migration[7.0]
  def change
    remove_column :settings, :dynamic_temp_factor
  end
end
