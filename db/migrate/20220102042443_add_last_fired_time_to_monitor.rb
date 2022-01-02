class AddLastFiredTimeToMonitor < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_monitors, :last_fired_at, :datetime
  end
end
