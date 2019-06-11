-- ****************************************************************************
--
-- Compatability wrapper for mapping ESP8266's ws2812 module API to ESP32
--
-- Usage:
--
--   ws2812 = require("ws2812_compat")(pin_strip1[, pin_strip2])
--
--     pin_strip1: GPIO pin of first led strip, mandatory
--     pin_strip2: GPIO pin of second led strip, optional
--
-- ****************************************************************************

local M = {}

local _pin_strip1, _pin_strip2
local _mode

local _ws2812


-- ****************************************************************************
-- Implement esp8266 compatability API
--
function init(mode)
  if _pin_strip2 == nil and mode == MODE_DUAL then
    error("gpio for data2 undefined")
  end

  _mode = mode or MODE_SINGLE
end

function write(data1, data2)
  if _mode == nil then
    error("call init() first")
  end

  local strip1 = {pin = _pin_strip1, data = data1}
  local strip2

  if _pin_strip2 and data2 then
    strip2 = {pin = _pin_strip2, data = data2}
  end

  _ws2812.write(strip1, strip2)
end

return function (pin_strip1, pin_strip2)
  -- cache built-in module
  _ws2812 = ws2812
  -- invalidate built-in module
  ws2812 = nil

  -- forward unchanged functions
  newBuffer = _ws2812.newBuffer

  -- forward constant definitions
  FADE_IN        = _ws2812.FADE_IN
  FADE_OUT       = _ws2812.FADE_OUT
  MODE_SINGLE    = 0   -- encoding from ws2812.c
  MODE_DUAL      = 1   -- encoding from ws2812.c
  SHIFT_LOGICAL  = _ws2812.SHIFT_LOGICAL
  SHIFT_CIRCULAR = _ws2812.SHIFT_CIRCULAR

  _pin_strip1 = pin_strip1 or error("pin_strip1 not defined")
  _pin_strip2 = pin_strip2

  return M
end