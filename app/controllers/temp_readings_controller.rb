class TempReadingsController < ApplicationController
  def index
    @temp_readings = TempReading.order(created_at: :desc).limit(20)
  end
end