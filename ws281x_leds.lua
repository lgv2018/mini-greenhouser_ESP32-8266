wsPin = 15
ws2812 = require("ws2812_compat")(wsPin)

local ZLed = {}
--ZLed = {}

pin = wsPin
strandLength = 4
buffer = ws2812.newBuffer(strandLength, 3); 
t = tmr.create()

ZLed.isBusy = false

function chase(r, g, b)
  local isRun, mode = ZLed.t:state()
  if isRun == true then return end
  --if ZLed.isBusy then return end
  --ZLed.isBusy = true
  if r == nil then r = 0 end
  if g == nil then g = 0 end
  if b == nil then b = 255 end
  local i = 0
  buffer:fill(0, 0, 0); 
  t:alarm(100, tmr.ALARM_AUTO, function()
    i = i + 1
    buffer:fade(5)
    buffer:set(i % buffer:size() + 1, g, r, b)
    ws2812.write({pin = pin, data = buffer})
  end)
end
ZLed.chase = chase

function pulse(r, g, b)
  print("Starting pulse animation")
  -- normal run  
  local isRun, mode = t:state()
  if isRun == true then return end
  --if ZLed.isBusy then return end
  --ZLed.isBusy = true
  if r == nil then r = 0 end
  if g == nil then g = 0 end
  if b == nil then b = 255 end
  local pulseCtr = 0
  local direction = 2
  -- buffer:fill(g, r, b);
  -- buffer:fade(5)
  ws2812.write({pin = pin, data = buffer})
  print("About to start AUTO alarm on pulse")
  t:alarm(10, tmr.ALARM_AUTO, function()
    pulseCtr = pulseCtr + direction
    local r2 = 0
    local g2 = 0
    local b2 = 0
    if pulseCtr <= 3 then direction = 2 end
    if pulseCtr >= 100 then direction = -2 end
    if pulseCtr <= r then r2 = pulseCtr end
    if pulseCtr <= g then g2 = pulseCtr end
    if pulseCtr <= b then b2 = pulseCtr end
    buffer:fill(g2, r2, b2);
    ws2812.write({pin = pin, data = buffer})
  end)
  -- buffer:fade(2, ws2812.FADE_IN)
end
pulse = pulse

function pause()
  if isBusy then
    t:stop()
    print("Paused LED anim")
    isBusy = false
  end
end
ZLed.pause = pause

function resume()
  if isBusy == false then
    local running, mode = t:state()
    if running ~= nil then
      -- means is registered
      isBusy = true
      t:start()
      print("Resumed LED anim")
    end
  end
end
ZLed.resume = resume

function fill(r, g, b)
  if r == nil then r = 0 end
  if g == nil then g = 0 end
  if b == nil then b = 0 end
  buffer:fill(g, r, b);
  ws2812.write({pin = pin, data = buffer})
end
ZLed.fill = fill


function stop()
  print("ZLed stop. Stopping other LED ops.")
  -- if ZLed.isBusy == false then
  --   print("Being asked to stop LED anim, but not running")
  --   return
  -- end
  local isRun, mode = t:state()
  if isRun == true then t:stop() end
  if isRun ~= nil then 
    t:unregister()
  end
  isBusy = false
  -- just do set color without fade to resolve possible bug
  fill(7, 3, 0) -- just enough to show we're on
  if true then return end
  local i = 0
  local tmrFadeBack = tmr.create()
  tmrFadeBack:alarm(100, tmr.ALARM_AUTO, function()
    i = i + 1
    buffer:fade(2)
    ws2812.write({pin = pin, data = buffer})
    if i > 30 then 
      tmrFadeBack:stop()
      tmrFadeBack:unregister()
      -- ZLed.fill(3, 2, 0) -- just enough to show we're on
      fill(7, 3, 0) -- just enough to show we're on
    end
  end)
  -- buffer:fill(0, 0, 0);
  -- ws2812.write({pin = ZLed.pin, data = buffer})
end
ZLed.stop = stop

function indicateDataSent()
   -- indicate to lights that we are starting our tcp request
  local isRun, mode = t:state()
  if isRun then return end
  --if ZLed.isBusy then return end
  print("indicateDataSent")
  led.buffer:set(1, 10, 0, 0)
  ws2812.write({pin = pin, data = led.buffer})
end
ZLed.indicateDataSent = indicateDataSent

function indicateDataRecvd()
  -- indicate to lights that we are done with our tcp request
  local isRun, mode = t:state()
  if isRun then return end
  --if ZLed.isBusy then return end
  print("indicateDataRecvd")
  -- led.buffer:set(1, 0, 0, 0)
  led.buffer:set(1, 3, 7, 0) -- base color of light orange
  ws2812.write({pin = pin, data = led.buffer})
end
ZLed.indicateDataRecvd = indicateDataRecvd

function indicateDataDisconnectErr()
 -- indicate to lights that we are done with our tcp request
  local isRun, mode = t:state()
  if isRun then return end
  --if ZLed.isBusy then return end
  led.buffer:set(1, 0, 10, 0)
  ws2812.write({pin = pin, data = led.buffer})
end
ZLed.indicateDataDisconnectErr = indicateDataDisconnectErr

-- ZLed.pulse(0, 0, 255)
--ZLed.chase(255, 0, 0)

return ZLed