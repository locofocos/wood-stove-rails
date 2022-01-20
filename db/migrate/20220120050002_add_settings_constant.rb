class AddSettingsConstant < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :static_temp_offset, :float
  end
end
