json.extract! settings, :id, :static_temp_factor, :dynamic_temp_factor, :max_rate_adjustment_delta, :created_at, :updated_at
json.url settings_url(settings, format: :json)
