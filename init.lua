-- Init.lua
print("Initializing...")

function getDhtData()
    status, temp, humi, temp_dec, humi_dec = dht.read2x(dhtpin)
    if status == dht.OK then
        print( "DHT Sensor reading good.")
        -- Integer firmware using this example
        --print(string.format("DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
        --      math.floor(temp),
        --      temp_dec,
        --      math.floor(humi),
        --      humi_dec
        --))

        -- Float firmware using this example
        -- print("DHT Temperature:"..temp..";".."Humidity:"..humi)

    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
end

function initDs18Sensors()
  ow.setup(dsPin)
  count = 0
  repeat
    count = count + 1
    addr = ow.reset_search(dsPin)
    addr = ow.search(dsPin)
  until (addr ~= nil) or (count > 100)
end

function readDs18Sensors()
  if addr == nil then
    print("No more addresses.")
  else
    -- debug output
    --print(addr:byte(1,8))
    crc = ow.crc8(string.sub(addr,1,7))
    if crc == addr:byte(8) then
      if (addr:byte(1) == 0x10) or (addr:byte(1) == 0x28) then
        print("Found a DS18S20 family device.")
          --repeat
            ow.reset(dsPin)
            ow.select(dsPin, addr)
            ow.write(dsPin, 0x44, 1)
--            tmr.delay(1000000)
            present = ow.reset(dsPin)
            ow.select(dsPin, addr)
            ow.write(dsPin,0xBE,1)
            -- debug output, num devices found
            --print("P="..present)  
            data = nil
            data = string.char(ow.read(dsPin))
            for i = 1, 8 do
              data = data .. string.char(ow.read(dsPin))
            end
            -- debug output
            --print(data:byte(1,9))
            crc = ow.crc8(string.sub(data,1,8))
            -- debug output
            -- print("CRC="..crc)
            if crc == data:byte(9) then
               t = (data:byte(1) + data:byte(2) * 256) * 625
               t1 = t / 10000
               t2 = t % 10000
               --print("Temperature="..t1.."."..t2.."Centigrade")
            end                   
          --until false
      else
        print("Device family is not recognized.")
      end
    else
      print("CRC is not valid!")
    end
  end
end

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

getDhtData()
--temp = dhts.getTemp()
--humi = dhts.getHumi()
print("DHT Temperature: "..temp.." ; ".."Humidity: "..humi)

-- ds18b20 sensor
print("Checking soil")
ds = require("ds18b20")
dsPin = 5
ds.initSensors()
dsReading = readDs18Sensors()

print("Soil temp: "..t1.."C°")