-- ds18b20 
dsPin = 19

local Ds = {}

function initSensors()
  ow.setup(dsPin)
  count = 0
  repeat
    count = count + 1
    addr = ow.reset_search(dsPin)
    addr = ow.search(dsPin)
  until (addr ~= nil) or (count > 100)
end

function readSensors()
  if addr == nil then
    print("No more addresses.")
  else
    print(addr:byte(1,8))
    crc = ow.crc8(string.sub(addr,1,7))
    if crc == addr:byte(8) then
      if (addr:byte(1) == 0x10) or (addr:byte(1) == 0x28) then
        print("Device is a DS18S20 family device.")
          repeat
            ow.reset(dsPin)
            ow.select(dsPin, addr)
            ow.write(dsPin, 0x44, 1)
            tmr.delay(1000000)
            present = ow.reset(dsPin)
            ow.select(dsPin, addr)
            ow.write(dsPin,0xBE,1)
            print("P="..present)  
            data = nil
            data = string.char(ow.read(dsPin))
            for i = 1, 8 do
              data = data .. string.char(ow.read(dsPin))
            end
            print(data:byte(1,9))
            crc = ow.crc8(string.sub(data,1,8))
            print("CRC="..crc)
            if crc == data:byte(9) then
               t = (data:byte(1) + data:byte(2) * 256) * 625
               t1 = t / 10000
               t2 = t % 10000
               print("Temperature="..t1.."."..t2.."Centigrade")
            end                   
          until false
      else
        print("Device family is not recognized.")
      end
    else
      print("CRC is not valid!")
    end
  end
end
Ds.readSensors = readSensors

return Ds