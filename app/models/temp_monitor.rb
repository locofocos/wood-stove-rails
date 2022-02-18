# reading_location - the temperature reading location that will be checked.
#   Possible values in the future: the stove internal temp, the stove sidewall, the stove's exhaust pipe, the room ambient temperature, etc.
class TempMonitor < ApplicationRecord

  READING_LOCATION_VALUES = ['INTERNAL_TEMPF', 'SURFACE_TEMPF']
  validates :reading_location, inclusion: READING_LOCATION_VALUES, presence: true

  # Process all monitors, possibly send out notifications
  def self.process_all
    TempMonitor.all.each do |temp_monitor|
      temp_monitor.process
    end
  end

  def process
    unless enabled
      Rails.logger.info("Skipping temp monitor #{id} because it's disabled")
      return
    end

    # This logic works okay. But if you have 2 notifications that might fire back to back, and you want to avoid that, it doesn't prevent the 2nd notification.
    # For example, a monitor "internal temp is too hot" and a monitor "surface temp is too hot".
    # The first notification got my attention, so I don't need another notification.
    # unless toggle_fan # we never want to skip toggling the fan because of its effect on the stove temp
    #
    #   fired_very_recently = last_fired_at && last_fired_at > 10.minutes.ago
    #   if fired_very_recently
    #     Rails.logger.info("Skipping temp monitor #{id} because it fired very recently")
    #     return
    #   end
    # end

    # Prevent sending back-to-back push notifications for different monitors
    last_notification_time = TempMonitor.where(send_notifications: true).pluck(:last_fired_at).compact.max
    if last_notification_time
      notification_fired_recently = last_notification_time > 5.minutes.ago
    else
      notification_fired_recently = false
    end

    second_to_last = TempReading.second_to_last
    last = TempReading.last

    loc = reading_location

    if upper_limitf
      has_crossed_upper_limit = second_to_last.temp_by_location(loc) < upper_limitf && last.temp_by_location(loc) >= upper_limitf

      if has_crossed_upper_limit
        if send_notifications
          title = "🔥 Upper temp limit crossed"
          body = "#{pretty_reading_location} crossed from #{helpers.number_to_human(second_to_last.temp_by_location(loc))} to #{helpers.number_to_human(last.temp_by_location(loc))}. Limit is #{upper_limitf}"
          Rails.logger.info(strip_emojis("#{title} - #{body}"))

          if notification_fired_recently
            Rails.logger.info("Skipping notification for temp monitor #{id} because another notification was sent recently")
          else
            send_push_notification!(title, body)
          end
          update!(last_fired_at: Time.now)
        end

        if toggle_fan
          RelayService.on
          update!(last_fired_at: Time.now)
        end
      end
    end

    if lower_limitf
      has_crossed_lower_limit = second_to_last.temp_by_location(loc) > lower_limitf && last.temp_by_location(loc) <= lower_limitf

      if has_crossed_lower_limit
        if send_notifications
          title = "❄️ Lower temp limit crossed"
          body = "#{pretty_reading_location} crossed from #{helpers.number_to_human(second_to_last.temp_by_location(loc))} to #{helpers.number_to_human(last.temp_by_location(loc))}. Limit is #{lower_limitf}"
          Rails.logger.info(strip_emojis("#{title} - #{body}"))

          if notification_fired_recently
            Rails.logger.info("Skipping notification for temp monitor #{id} because another notification was sent recently")
          else
            send_push_notification!(title, body)
          end

          update!(last_fired_at: Time.now)
        end

        if toggle_fan
          RelayService.off
          update!(last_fired_at: Time.now)
        end
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

  def pretty_reading_location
    reading_location.humanize
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
