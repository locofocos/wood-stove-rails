class RelaysController < ApplicationController

  def new
  end

  def create
    raise "power param missing" unless params[:power].present?

    if params[:power] == 'on'
      RelayService.on
    else
      RelayService.off
    end

    respond_to do |format|
      format.html { redirect_to relays_url, notice: "Fan was successfully toggled" }
    end
  end
end
