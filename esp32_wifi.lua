-- ChiliPeppr Wifi connect library
-- This library lets you connect to Wifi and get some nice callbacks
-- It supports multiple wifi ssid/passwords
-- where it iterates over them 
-- to try multiple networks

-- To use:
-- wif = require("esp32_wifi")
-- wif.on("connection", function(ip)
--   print("Got wifi. IP:", ip)
-- end)
-- wif.init()

local m = {}
-- m = {}

-- provide a list of Wifi networks
m.wifiAuth = {}
m.wifiAuth[0] = {ssid = "Tell My WiFi Love Her", password = "45c13nc3!"}
m.wifiAuth[1] = {ssid = "BDV_OR", password = "bdvavcx613"}
m.wifiAuth[2] = {ssid = "cameras", password = "45c13nce!"}
m.wifiAuth[3] = {ssid = "Bill Wi The Science Fi", password = "45c13nc3!"}

-- private properties
m.isInitted = false
m.myIp = nil
m.isConn = false

function m.init()
  if m.myIp == nil then
    print("Attempting to connect to wifi...")
    m.setupWifi()
  else 
    -- print("My IP: " .. m.myIp)
    m.isInitted = true
  end
end

function m.isConnected()
  if m.myIp == nil then 
    return false
  else 
    return true
  end
end 

m.wifiAuthItem = 0

function m.setupWifi()
  --register callback
  wifi.sta.on("got_ip", m.gotIp)
  wifi.sta.on("start", function() print "Wifi started" end)
  wifi.sta.on("stop", function() print "Wifi stopped" end)
  wifi.sta.on("connected", function(event, info) 
    print("Wifi connected. ssid:", info.ssid, ", bssid:", info.bssid, ", channel:", info.channel, ", auth:", info.auth)
    print("We should then get an ip...")
  end)

wifi.sta.on("disconnected", function(event, info) 
    -- set our ip to nil cuz that's our indicator of connected
    m.myIp = nil
    m.isConn = false
  print("Wifi disconnected. ssid:", info.ssid, ", bssid:", info.bssid, ", reason:", info.reason)
    -- for key,value in pairs(data) do print(key,value) end
    if m.onDisconnectCallback then m.onDisconnectCallback(info) end
    -- try to use next entry in wifi name/pass list if there is one
    m.wifiAuthItem = m.wifiAuthItem + 1
    if #m.wifiAuth < m.wifiAuthItem then
      print("We have no more entries to analyze. Going to start of list")
    m.wifiAuthItem = 0
    end
    print("Attempting to connect to wifi:", m.wifiAuth[m.wifiAuthItem].ssid, " with password:", m.wifiAuth[m.wifiAuthItem].password )
    station_cfg={}
    station_cfg.ssid = m.wifiAuth[m.wifiAuthItem].ssid 
    station_cfg.pwd = m.wifiAuth[m.wifiAuthItem].password 
    wifi.sta.config(station_cfg, true)
  end)

  wifi.sta.on("authmode_changed", function(event, info)
    print("Wifi authmode_changed. old_mode:", info.old_mode, ", new_mode:", info.new_mode)
    -- for key,value in pairs(data) do print(key,value) end
  end)

  -- set as station
  wifi.mode(1)
  wifi.stop()
  -- start wifi
  wifi.start()

  --connect to Access Point (DO save config to flash)
  station_cfg={}
  station_cfg.ssid = m.wifiAuth[0].ssid 
  station_cfg.pwd = m.wifiAuth[0].password 
  wifi.sta.config(station_cfg, true)
  -- print("Saved wifi name/password")
end

function m.gotIp(ev, info)
  print("Oh, we got ourselves an IP:", info.ip, ", Netmask:", info.netmask, ", GW:", info.gw)
  m.myIp = info.ip
  m.isConn = true
  if m.onConnectedCallback then m.onConnectedCallback(info) end 
  -- make sure we are initted
  m.init()
end

function m.getIp()
  return m.myIp
end 

m.onConnectedCallback = nil
m.onDisconnectCallback = nil
function m.on(method, func)
  if method == "connection" then
    m.onConnectedCallback = func 
  elseif method == "disconnection" then
    m.onDisconnectCallback = func
  end 
end
-- m.init()
return m