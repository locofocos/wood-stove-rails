# frozen_string_literal: true

namespace :temp_reading do
  desc 'Rad the current temperature from the sensor and create a new TempReading record with the value'
  task log: :environment do
    TempReading.log
  end
end
