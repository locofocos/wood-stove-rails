# frozen_string_literal: true

class CurrentTemp

  def self.read_fahrenheit
    start_time = Time.now
    raw = `python lib/read_temp.py`.strip
    end_time = Time.now
    Rails.logger.info("read raw temp: #{raw}, took #{end_time - start_time} seconds")
    raw.to_f
  end
end
