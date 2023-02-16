# static_temp_factor  - Surface temp factor. Fix temperature reading off when the temp is staying steady. Increasing this raises higher temperatures more than low temperatures.
# static_temp_offset - Surface temp offset. Fix temperature reading off when the temp is staying steady. Increasing this raises all temperatures equally.
# dynamic_up_temp_factor -   Dynamic/internal temp factor (fix temperature reading when the temp is rising quickly)
# dynamic_down_temp_factor - Dynamic/internal temp factor (fix temperature reading when the temp is falling quickly)
# max_rate_adjustment_delta - Max rate adjustment delta (when the temp is changing quickly, don't rate-adjust the internal temperature more than this number of degrees)
class Settings < ApplicationRecord
end
