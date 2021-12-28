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
    if raw_tempf
      (raw_tempf * 2.1) - 70
    else
      tempf
    end
  end

  # Read the current temperature from the sensor and create a new TempReading record with the value.
  # Process temperature monitors.
  # probably raises some parse error if reading fails
  def self.log!
    raw_tempf = CurrentTemp.read_fahrenheit_raw

    record = TempReading.create!(raw_tempf: raw_tempf)
    record.derive_temps
    record.save!
    Rails.logger.info("Saved temperature: #{record.tempf} (raw: #{record.raw_tempf})")

    TempMonitor.process_all

    record
  end

  def derive_temps!
    derive_temps
    save!
  end

  # Derive temps which are based on raw_tempf (and possibly other TempReadings).
  # Might call this after initial creation, when you realize that your constant factors
  # in temp algorithms need to be adjusted (like when these readings don't align with a physical thermometer).
  def derive_temps
    # 2.1 and 70 - derived from trial and error with real values. Designed to keep it correct at room temperature.
    # Basically account for the sensor not picking up all the heat, for whatever reason.
    adjusted_tempf = (raw_tempf * 2.1) - 70

    # Attempt to calculate the actual stove temperature based on the current rate of temperature change.
    # Temp rising much faster right now -> the true temp is much higher than the current reading.
    recent_reading = TempReading.find_by(created_at: (created_at - 2.5.minutes)...(created_at - 1.5.minutes))

    if recent_reading && recent_reading.raw_tempf
      adjustment_delta = (raw_tempf - recent_reading.raw_tempf) * 16 # 16 is derived from trial and error

      adjusted_tempf += adjustment_delta
    end

    assign_attributes(tempf: adjusted_tempf)
  end
end
