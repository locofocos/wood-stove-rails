# static_temp_factor  - Surface temp factor (fix temperature reading off when the temp is staying steady)
# dynamic_temp_factor - Dynamic/internal temp factor (fix temperature reading when the temp is changing quickly)
# max_rate_adjustment_delta - Max rate adjustment delta (when the temp is changing quickly, don't rate-adjust the internal temperature more than this number of degrees)
class Settings < ApplicationRecord
end
