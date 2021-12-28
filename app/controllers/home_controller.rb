# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    reading = TempReading.last
    @current_tempf = reading.tempf
    @current_raw_tempf = reading.raw_tempf
  rescue StandardError => e
    Rails.logger.error(e)
    render plain: "Error: #{e}"
  end
end
