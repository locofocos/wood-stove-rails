# frozen_string_literal: true

class TempReadingsController < ApplicationController

  INTERNAL_TEMP_COLOR = 'orange'
  SURFACE_TEMP_COLOR = 'gray'

  def index
    limit = params[:limit].present? ? params[:limit].to_i : 30
    offset = params[:offset].present? ? params[:offset].to_i : 0
    @temp_readings = TempReading.order(created_at: :desc).limit(limit).offset(offset).to_a

    @settings = Settings.first

    if @temp_readings.first&.tempf
      tempf = @temp_readings.first.tempf
      @extra_tab_title = "#{helpers.number_to_human(tempf)} °F #{color_emoji_for_temp(tempf)} "
    end

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

  private

  def color_emoji_for_temp(tempf)
    if tempf >= 650
      '🔴'
    elsif tempf >= 400
      '🟠'
    elsif tempf >= 250
      '🟡'
    else
      '⚪'
    end
  end

  # use view helpers outside of views https://stackoverflow.com/questions/5176718/how-to-use-the-number-to-currency-helper-method-in-the-model-rather-than-view
  def helpers
    ActionController::Base.helpers
  end
end
