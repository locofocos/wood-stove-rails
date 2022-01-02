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
      static_temp_factor = Settings.first&.static_temp_factor || 2.1
      (raw_tempf * static_temp_factor) - 70
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
    static_temp_factor = Settings.first&.static_temp_factor || 2.1
    adjusted_tempf = (raw_tempf * static_temp_factor) - 70

    # Attempt to calculate the actual stove temperature based on the current rate of temperature change.
    # Temp rising much faster right now -> the true temp is much higher than the current reading.

    older_reading = TempReading.find_by(created_at: (created_at - 2.5.minutes)...(created_at - 1.5.minutes))
    old_reading = TempReading.find_by(created_at: (created_at - 1.5.minutes)...(created_at - 0.5.minutes))

    if older_reading&.raw_tempf && old_reading&.raw_tempf
      dynamic_temp_factor = Settings.first&.dynamic_temp_factor || 16 # 16 is derived from trial and error

      adjustment_delta1 = calc_adjustment_delta(older_reading, old_reading, dynamic_temp_factor)
      adjustment_delta2 = calc_adjustment_delta(old_reading, self, dynamic_temp_factor)
      adjustment_delta3 = calc_adjustment_delta(older_reading, self, dynamic_temp_factor)

      # choose the most conservative adjustment_delta among the last few readings, to smooth over data that has subtle outliers
      adjustment_delta = [adjustment_delta1, adjustment_delta2, adjustment_delta3].min { |a,b| a.abs <=> b.abs }

      adjusted_tempf += adjustment_delta
    end

    assign_attributes(tempf: adjusted_tempf)
  end

  # adjustment delta = how much we should adjust the current adjusted_tempf to achieve our best guess at the current real temperature
  def calc_adjustment_delta(first_reading, second_reading, dynamic_temp_factor)
    # none of these should happen, calling code should avoid
    raise 'first_reading must have a raw_tempf' unless first_reading.raw_tempf
    raise 'second_reading must have a raw_tempf' unless second_reading.raw_tempf
    raise 'first_reading must be before second_reading' unless first_reading.created_at < second_reading.created_at

    minutes_between = (second_reading.created_at - first_reading.created_at) / 60

    adjustment_delta = (second_reading.raw_tempf - first_reading.raw_tempf) * dynamic_temp_factor * 2 / minutes_between
    adjustment_delta
  end
end
