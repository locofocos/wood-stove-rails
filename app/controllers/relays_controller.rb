class RelaysController < ApplicationController

  def new
  end

  def create
    puts "params is: #{params}"

    #TODO set relay values

    respond_to do |format|
      format.html { redirect_to relays_url, notice: "Relay was successfully toggled" }
    end
  end
end
