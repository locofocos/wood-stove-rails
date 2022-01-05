class TempReadingsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "temp_readings_broadcasting"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
