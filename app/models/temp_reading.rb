# frozen_string_literal: true

# temp_f - our best approximation of the internal temperature of the stove
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

  def temp_by_location(location)
    raise "Unknown location #{location}" unless TempMonitor::READING_LOCATION_VALUES.include? location

    case location
    when 'INTERNAL_TEMPF'
      return tempf
    when 'SURFACE_TEMPF'
      return surface_tempf
    else
      raise "Unhandled location #{location}"
    end
  end

  # Surface temperature == the non-rate-adjusted temperature.
  # Adjust for the sensor not picking up all the heat.
  # But NOT adjusted to account for the rate of change.
  def surface_tempf
    # There's not a big reason not to persist this in the db. It just evolved this way out of convenience.
    # Might need to persist this value for performance one day.
    if raw_tempf
      static_temp_factor = settings&.static_temp_factor || 2.1
      (raw_tempf * static_temp_factor) - 70
    else
      tempf
    end
  end

  def settings
    @settings ||= Settings.first
  end

  # Read the current temperature from the sensor and create a new TempReading record with the value.
  # Process temperature monitors.
  # probably raises some parse error if reading fails
  def self.log!
    raw_tempf = CurrentTemp.read_fahrenheit_raw

    if raw_tempf == 0
      # retry. IO is finicky every now and then.
      sleep 0.5
      raw_tempf = CurrentTemp.read_fahrenheit_raw
    end

    if raw_tempf == 0
      raise 'Unable to read temperature'
    end

    record = TempReading.create!(raw_tempf: raw_tempf)
    record.derive_temps
    record.save!
    Rails.logger.info("Saved temperature: #{record.tempf} (raw: #{record.raw_tempf})")

    TempMonitor.process_all

    data = 'hello world'
    ActionCable.server.broadcast("temp_readings_broadcasting", data) # tell clients to refresh their page to view new temps

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

      # If this is configured in settings for 100 F,
      # then don't allow max_rate_adjustment_delta to go above 100 or below -100.
      max_rate_adjustment_delta = Settings.first&.max_rate_adjustment_delta
      if max_rate_adjustment_delta
        adjustment_delta = [adjustment_delta, max_rate_adjustment_delta].min
        adjustment_delta = [adjustment_delta, -1 * max_rate_adjustment_delta].max
      end

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
