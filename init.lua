-- Init.lua
print("Initializing...")

-- WS2812 Control
neoPixel = require("ws281x_leds")
--neoPixel.chase(255, 0, 0)

-- I2C SSD1306
zd = require('zipwhip_oled')
zd.setupDisplay()
zd.showText("Initializing...")

-- Wifi init
wf = require("esp32_wifi")
wf.init()
wf.on("connection", function(info)
  print("Got wifi. IP:", info.ip, "Netmask:", info.netmask, "GW:", info.gw)
  zd.showText("IP address:" , info.ip)
end)

-- DHT Sensor
print("Checking air")
dhts = require('dht_sensor')
dhtpin=4

dhts.getTemp()
dhts.getHumi()
print("DHT Temperature:"..temp..";".."Humidity:"..humi)

-- ds18b20 sensor
print("Checking soil")
ds = require("ds18b20")
dspin = 19
ds.initSensors()
ds.readSensors()