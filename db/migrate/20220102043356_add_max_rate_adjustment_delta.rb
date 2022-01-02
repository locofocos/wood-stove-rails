class AddMaxRateAdjustmentDelta < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :max_rate_adjustment_delta, :integer
  end
end
