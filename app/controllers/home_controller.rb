# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    reading = TempReading.log!
    @current_tempf = reading.tempf
  rescue StandardError => e
    Rails.logger.error(e)
    render plain: "Error: #{e}"
  end
end
