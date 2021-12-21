# frozen_string_literal: true

class TempReading < ApplicationRecord
  # [ tempf, adjusted_tempf]
  TEMP_ADJUSTMENTS = [
    { tempf: 265, adjusted_tempf: 400 },
    { tempf: 300, adjusted_tempf: 450 } # example
  ].freeze

  # tempf stores the raw sensor value, which can be off due to the positioning of the sensor.
  def adjusted_tempf
    lower = TEMP_ADJUSTMENTS.select { |adj| adj[:tempf] < tempf }.max_by { |adj| adj[:tempf] }
    upper = TEMP_ADJUSTMENTS.select { |adj| adj[:tempf] > tempf }.min_by { |adj| adj[:tempf] }

    return nil unless lower.present? && upper.present?

    percent_between = (tempf.to_f - lower[:tempf]) / (upper[:tempf] - lower[:tempf])

    # linear interpolation
    lower[:adjusted_tempf] +
      ((upper[:adjusted_tempf] - lower[:adjusted_tempf]) * percent_between)
  end

  def pretty_timestamp
    created_at.in_time_zone('US/Central').strftime('%I:%M %p %b %d')
  end

  # Read the current temperature from the sensor and create a new TempReading record with the value.
  # Process temperature monitors.
  def self.log
    log!
  rescue StandardError => e
    Rails.logger.error("Unable to log current temperature: #{e}")
  end

  # Read the current temperature from the sensor and create a new TempReading record with the value.
  # Process temperature monitors.
  # probably raises some parse error if reading fails
  def self.log!
    current_temp = CurrentTemp.read_fahrenheit
    record = TempReading.create!(tempf: current_temp)
    Rails.logger.info("Saved temperature: #{current_temp}")

    TempMonitor.process_all

    record
  end
end
