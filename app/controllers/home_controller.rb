# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    reading = TempReading.log!
    render plain: "hello world! current temp is #{reading.tempf}"
  rescue StandardError => e
    Rails.logger.error(e)
    render plain: "Error: #{e}"
  end
end
