class TempMonitor < ApplicationRecord

  # Process all notifications
  def self.process_all
    TempMonitor.all.each do |temp_monitor|
      temp_monitor.process
    end
  end

  def process
    second_to_last = TempReading.second_to_last
    last = TempReading.last

    #TODO make some way to avoid this firing too frequently. Mainly when the value barely fluctuates around the limit.
    # Or maybe there needs to be a resolution threshold.

    if upper_limitf
      has_crossed_upper_limit = second_to_last.tempf < upper_limitf && last.tempf >= upper_limitf
      if has_crossed_upper_limit
        title = "🔥 Upper temp limit crossed"
        body = "Crossed from #{number_to_human(second_to_last.tempf)} to #{number_to_human(last.tempf)}. Limit is #{upper_limitf}"
        Rails.logger.info("#{title} - #{body}")

        send_push_notification!(title, body)
      end
    end

    if lower_limitf
      has_crossed_lower_limit = second_to_last.tempf > lower_limitf && last.tempf <= lower_limitf

      if has_crossed_lower_limit
        title = "❄️ Lower temp limit crossed"
        body = "Crossed from #{number_to_human(second_to_last.tempf)} to #{number_to_human(last.tempf)}. Limit is #{lower_limitf}"
        Rails.logger.info("#{title} - #{body}")

        send_push_notification!(title, body)
      end
    end
  end


  def send_push_notification!(title, body)
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://api.pushbullet.com/v2/pushes")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"

    pushbullet_access_token = ENV['PUSHBULLET_ACCESS_TOKEN']
    raise "Couldn't find ENV['PUSHBULLET_ACCESS_TOKEN']" unless pushbullet_access_token.present?

    request["Access-Token"] = pushbullet_access_token
    request.body = JSON.dump({
                                 "body" => body,
                                 "title" => title,
                                 "type" => "note"
                             })

    req_options = {
        use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    Rails.logger.info("Sent push notification. response.code = #{response.code}, response.body = #{response.body}")

    if response.code == 200
      return
    else
      raise "Push notification failed! response.body: #{response.body}"
    end
  end
end
