# frozen_string_literal: true

class CurrentTemp
  # linear interpolation control points
  # tempf = what the MLX90614 reads, the raw value
  # adjusted_tempf = what the physical old fashioned wood stove temp sensor reads
  # TEMP_ADJUSTMENTS = [
  #   { tempf: 70, adjusted_tempf: 70 },
  #   { tempf: 265, adjusted_tempf: 400 },
  #   { tempf: 291, adjusted_tempf: 425 },
  #   { tempf: 265 + (265 - 70), adjusted_tempf: 400 + (400 - 70) } # poor man's extrapolation. Replace with better observed values.
  # ].freeze

  def self.read_fahrenheit
    raw = read_fahrenheit_raw
    adjusted_tempf(raw)
  end

  def self.read_fahrenheit_raw
    start_time = Time.now
    raw = `python lib/read_temp.py`.strip
    end_time = Time.now
    Rails.logger.info("read raw temp: #{raw}, took #{end_time - start_time} seconds")
    raw.to_f
  end

  # raw is the raw sensor value, which can be off due to the positioning of the sensor.
  # Adjust the data before persisting so that everything else in the app is simpler (only 1 set of temperature values).
  def self.adjusted_tempf(raw)
    raw * 1.7 - 70 # let's try a constant factor. Probably most likely.
  end

  # def self.adjusted_tempf(raw)
  #   lower = TEMP_ADJUSTMENTS.select { |adj| adj[:tempf] < raw }.max_by { |adj| adj[:tempf] }
  #   upper = TEMP_ADJUSTMENTS.select { |adj| adj[:tempf] > raw }.min_by { |adj| adj[:tempf] }
  #
  #   raise "Could not find interpolation points for temp #{raw}" unless lower.present? && upper.present?
  #
  #   percent_between = (raw.to_f - lower[:tempf]) / (upper[:tempf] - lower[:tempf])
  #
  #   # linear interpolation
  #   lower[:adjusted_tempf] +
  #     ((upper[:adjusted_tempf] - lower[:adjusted_tempf]) * percent_between)
  # end
end
