class ConfirmedReadingsController < ApplicationController

  def new
  end

  def create
    reading = TempReading.last!
    reading.update!(confirmed_tempf: params[:confirmed_tempf].to_i)

    respond_to do |format|
      format.html do
        redirect_to temp_readings_path,
                    notice: 'Successfully saved confirmed temp reading. View it on the graph.'
      end
    end
  end
end
