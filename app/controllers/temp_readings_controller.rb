# frozen_string_literal: true

class TempReadingsController < ApplicationController

  INTERNAL_TEMP_COLOR = 'orange'
  SURFACE_TEMP_COLOR = 'gray'

  def index
    limit = params[:limit].present? ? params[:limit].to_i : 30
    offset = params[:offset].present? ? params[:offset].to_i : 0
    @temp_readings = TempReading.order(created_at: :desc).limit(limit).offset(offset)

    @monitors_for_chart = []
    TempMonitor.where(enabled: true).each do |monitor|
      base_name = monitor.title.present? ? monitor.title : "Monitor #{monitor.id}"

      # Pick a color for the monitor threshold line to clarify which temp reading is being measured by that limit.
      case monitor.reading_location
      when 'INTERNAL_TEMPF'
        color = INTERNAL_TEMP_COLOR
      when 'SURFACE_TEMPF'
        color = SURFACE_TEMP_COLOR
      else
        raise "Unknown location #{monitor.reading_location}"
      end

      if monitor.upper_limitf
        name = "#{base_name} upper"
        monitor.upper_limitf
        @monitors_for_chart << { name: name, value_f: monitor.upper_limitf, color: color }
      end

      if monitor.lower_limitf
        name = "#{base_name} lower"
        monitor.lower_limitf
        @monitors_for_chart << { name: name, value_f: monitor.lower_limitf, color: color }
      end
    end
  end
end
