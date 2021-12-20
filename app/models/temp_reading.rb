# frozen_string_literal: true

class TempReading < ApplicationRecord
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
