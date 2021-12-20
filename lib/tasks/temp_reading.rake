# frozen_string_literal: true

namespace :temp_reading do
  desc 'Rad the current temperature from the sensor and create a new TempReading record with the value'
  task log: :environment do
    current_temp = CurrentTemp.read_fahrenheit
    TempReading.create!(tempf: current_temp)

    Rails.logger.info("Saved temperature: #{current_temp}")
  rescue StandardError => e
    Rails.logger.error("Unable to log current temperature: #{e}")
  end
end
