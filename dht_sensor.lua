-- DHT Sensor
dhtpin = 4

local Dt = {}
local humi
local temp
local temp_dec
local humi_dec

function getData()
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
Dt.getData = getData

function getHumi()
    getData(dhtpin)
    return humi
end
Dt.getHumi = getHumi

function getTemp()
    getData(dhtpin)
    return temp
end
Dt.getTemp = getTemp

function getHumi_dec()
    getData(dhtpin)
    return humi_dec
end
Dt.getHumi_dec = getHumi_dec

function getTemp_dec()
    getData(dhtpin)
    return humi_dec
end
Dt.getTemp_dec = getTemp_dec

return Dt