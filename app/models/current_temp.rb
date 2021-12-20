# frozen_string_literal: true

class CurrentTemp
  def self.read
    raw = `python lib/read_temp.py`
    Rails.logger.info("read raw temp: #{raw}")
    raw.strip.to_f
  end
end
