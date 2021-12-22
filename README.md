# README

Setup rails on your raspberry pi
```
# https://joelc.io/install-ruby-rails-raspberry-pi
# Slow official way

sudo apt-get install screen
screen bash

sudo apt update
sudo apt install -y curl build-essential zlib1g-dev libreadline-dev libssl-dev libxml2-dev
gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable --rails

# ctrl+A   D   to disconnect but leave it runnning
# ctrl+D       to kill it
# screen -r # to reconnect
```

Seed some data:
```
bin/rails db:migrate RAILS_ENV=development
TempReading.create(tempf: 50.0) # create at least one so that TempMonitor logic depending on comparing to previous doesn't break

TempMonitor.create!(upper_limitf: 500, lower_limitf: 60)
```

Set PUSHBULLET_ACCESS_TOKEN env variable, grab one from https://www.pushbullet.com/#settings. Needed for notifications
```
sudo vi /etc/profile
export PUSHBULLET_ACCESS_TOKEN=asdf
:wq
```

Start the rails server:
```
bundle install
rails s -b 192.168.1.188

# or in the background
screen rails s -b 192.168.1.188
# then ctrl+A   D
```

Control cron jobs for recording temp info (and processing monitors/notifications):
```
# Turn them on
bundle exec whenever --update-crontab --set environment='development' # see config/schedule.rb

# Turn them off
bundle exec whenever --clear-crontab
```

Control monitors (still needs a rails ui to be built) inside `rails c`:
```
# Update monitor thresholds
TempMonitor.last.update!(upper_limitf: 500, lower_limitf: 60)

# Disable monitors (maybe you want to keep cron jobs recording data but stop notifications):
TempMonitor.last.update!(upper_limitf: nil, lower_limitf: nil)
```


## Hardware

Enable i2c and friends
```
# Setup i2c. Chapter 7 of freenove manual. https://freenove.com/tutorial.html "Configure I2C and Install Smbus"
sudo raspi-config
# Choose “Interfacing Options” then “P5 I2C” then “Yes” and then “Finish” in this order and restart your RPi.

lsmod | grep i2c # check whether the I2C module is started:

#i2cdetect -y 1
#i2cdump -y 1 0x5a w
pip install smbus
```

Wire up the MLX90614 temp sensor.

Other useful links regarding this sensor:
* https://www.amazon.com/gp/product/B071VF2RWM/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1
* https://olegkutkov.me/2017/08/10/mlx90614-raspberry/
* https://www.raspberrypi.org/forums/viewtopic.php?t=17738

