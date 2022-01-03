# frozen_string_literal: true

class TempReadingsController < ApplicationController
  def index
    limit = params[:limit].present? ? params[:limit].to_i : 30
    @temp_readings = TempReading.order(created_at: :desc).limit(limit)

    @monitors_for_chart = []
    TempMonitor.all.each do |monitor|
      if monitor.upper_limitf
        name = "Monitor #{monitor.id} upper"
        monitor.upper_limitf
        color = 'orange' # to match the color of the internal temp line. to clarify that this limit applies to the orange data line.
        @monitors_for_chart << { name: name, value_f: monitor.upper_limitf, color: color }
      end

      if monitor.lower_limitf
        name = "Monitor #{monitor.id} lower"
        monitor.lower_limitf
        color = 'orange' # to match the color of the internal temp line. to clarify that this limit applies to the orange data line.
        @monitors_for_chart << { name: name, value_f: monitor.lower_limitf, color: color }
      end
    end
  end
end
