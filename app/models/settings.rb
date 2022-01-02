# static_temp_factor  - fix temperature reading off when the temp is staying steady
# dynamic_temp_factor - fix temperature reading when the temp is changing quickly
# max_rate_adjustment_delta - when the temp is changing quickly, don't rate-adjust the temperature more than this number of degrees
class Settings < ApplicationRecord
end
