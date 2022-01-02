
# Turn the relay on/off. The relay should enable/disable the wood stove fan.
# Example relay: https://www.amazon.com/gp/product/B01G05KLIE/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1
# Wire up the wood stove to the middle relay, GPIO pin 20, or customize below.
class RelayService

  GPIO_PIN_NUMBER = 20
  IO_SLEEP = 0.05

  def self.on
    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/export`
    sleep(IO_SLEEP)

    `echo out > /sys/class/gpio/gpio#{GPIO_PIN_NUMBER}/direction`
    sleep(IO_SLEEP)

    `echo 0 > /sys/class/gpio/gpio#{GPIO_PIN_NUMBER}/value`
    sleep(IO_SLEEP)

    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/unexport`
    sleep(IO_SLEEP)
  rescue StandardError => e
    Rails.logger.error("Error occurred while toggling relay: #{e}")
    sleep(IO_SLEEP)
    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/unexport`
  end

  def self.off
    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/export`
    sleep(IO_SLEEP)
    `echo out > /sys/class/gpio/gpio#{GPIO_PIN_NUMBER}/direction`
    sleep(IO_SLEEP)

    `echo 1 > /sys/class/gpio/gpio#{GPIO_PIN_NUMBER}/value`
    sleep(IO_SLEEP)

    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/unexport`
    sleep(IO_SLEEP)
  rescue StandardError => e
    Rails.logger.error("Error occurred while toggling relay: #{e}")
    sleep(IO_SLEEP)
    `echo #{GPIO_PIN_NUMBER} > /sys/class/gpio/unexport`
  end
end
