# frozen_string_literal: true

class TempReading < ApplicationRecord

  attr_acccessor :raw_tempf # generally only set when the object is first created

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
    raw_tempf = CurrentTemp.read_fahrenheit_raw
    adjusted = CurrentTemp.adjusted_tempf(raw_tempf)
    record = TempReading.create!(tempf: adjusted, raw_tempf: raw_tempf)
    Rails.logger.info("Saved temperature: #{record.tempf}")

    TempMonitor.process_all

    record
  end
end
