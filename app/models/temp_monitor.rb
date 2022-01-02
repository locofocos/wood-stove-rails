class TempMonitor < ApplicationRecord

  # Process all monitors, possibly send out notifications
  def self.process_all
    TempMonitor.all.each do |temp_monitor|
      temp_monitor.process
    end
  end

  def process
    fired_very_recently = last_fired_at && last_fired_at > 10.minutes.ago
    if fired_very_recently
      Rails.logger.info("Skipping temp monitor #{id} because it fired very recently")
      return
    end

    second_to_last = TempReading.second_to_last
    last = TempReading.last

    #TODO make some way to avoid this firing too frequently. Mainly when the value barely fluctuates around the limit.
    # Or maybe there needs to be a resolution threshold.

    if upper_limitf
      has_crossed_upper_limit = second_to_last.tempf < upper_limitf && last.tempf >= upper_limitf
      if has_crossed_upper_limit
        title = "🔥 Upper temp limit crossed"
        body = "Crossed from #{helpers.number_to_human(second_to_last.tempf)} to #{helpers.number_to_human(last.tempf)}. Limit is #{upper_limitf}"
        Rails.logger.info(strip_emojis("#{title} - #{body}"))

        send_push_notification!(title, body)
        update!(last_fired_at: Time.now)
      end
    end

    if lower_limitf
      has_crossed_lower_limit = second_to_last.tempf > lower_limitf && last.tempf <= lower_limitf

      if has_crossed_lower_limit
        title = "❄️ Lower temp limit crossed"
        body = "Crossed from #{helpers.number_to_human(second_to_last.tempf)} to #{helpers.number_to_human(last.tempf)}. Limit is #{lower_limitf}"
        Rails.logger.info(strip_emojis("#{title} - #{body}"))

        send_push_notification!(title, body)
        update!(last_fired_at: Time.now)
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

    Rails.logger.info(strip_emojis("Sent push notification. response.code = #{response.code}, response.body = #{response.body}"))

    if response.code.to_i == 200
      return
    else
      raise "Push notification failed! response.body: #{response.body}"
    end
  end

  private

  # use view helpers outside of views https://stackoverflow.com/questions/5176718/how-to-use-the-number-to-currency-helper-method-in-the-model-rather-than-view
  def helpers
    ActionController::Base.helpers
  end

  # for some reason, logging strings containing emojis fails
  def strip_emojis(str)
    str.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
  end
end
