class TempReadingsController < ApplicationController
  def index
    limit = params[:limit].to_i || 30
    @temp_readings = TempReading.order(created_at: :desc).limit(limit)
  end
end
