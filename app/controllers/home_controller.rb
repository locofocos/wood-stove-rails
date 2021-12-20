# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    @current_temp = CurrentTemp.read
    render plain: "hello world! current temp is #{@current_temp}"
  rescue StandardError => e
    Rails.logger.error(e)
    render plain: "Error: #{e}"
  end
end
