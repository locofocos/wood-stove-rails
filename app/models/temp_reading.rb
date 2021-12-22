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

  # Adjust for the sensor not picking up all the heat.
  # But NOT adjusted to account for the rate of change.
  def non_rate_adjusted_tempf
    (raw_tempf * 2.1) - 70
  end

  # Read the current temperature from the sensor and create a new TempReading record with the value.
  # Process temperature monitors.
  # probably raises some parse error if reading fails
  def self.log!
    raw_tempf = CurrentTemp.read_fahrenheit_raw

    # 2.1 and 70 - derived from trial and error with real values. Designed to keep it correct at room temperature.
    # Basically account for the sensor not picking up all the heat, for whatever reason.
    adjusted_tempf = (raw_tempf * 2.1) - 70

    # Attempt to calculate the actual stove temperature based on the current rate of temperature change.
    # Temp rising much faster right now -> the true temp is much higher than the current reading.
    recent_reading = TempReading.find_by(created_at: 2.5.minutes.ago...1.5.minutes.ago)

    if recent_reading && recent_reading.raw_tempf
      adjustment_delta = (raw_tempf - recent_reading.raw_tempf) * 16 # 16 is derived from trial and error

      adjusted_tempf += adjustment_delta
    end

    record = TempReading.create!(tempf: adjusted_tempf, raw_tempf: raw_tempf)
    Rails.logger.info("Saved temperature: #{record.tempf} (raw: #{record.raw_tempf})")

    TempMonitor.process_all

    record
  end
end
