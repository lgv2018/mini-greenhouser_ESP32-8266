
-- Display lua

-- Zipwhip OLED Display for showing text message info



-- Fonts include font_6x10_tf, font_unifont_t_symbols. 

-- U8g2 display types include i2c and spi for 

-- U8G2_I2C_SSD1306_128X64_NONAME and U8G2_SPI_SSD1306_128X64_NONAME 
-- which lets you use the Wemos built-in OLED displays from their 
-- Aliexpress/Banggood stores.

-- To use:
-- zd = require('zipwhip_oled')

local Zd = {}
-- Zd = {}

-- Make this global so xbmimage files don't have their own
-- display method that loads in RAM like this one

local function setupDisplay()
    -- only setup display if disp not created yet
    if disp ~= nil then return end
    id  = i2c.HW0
    sda = 21 --16
    scl = 22 --17
    i2c.setup(id, sda, scl, i2c.FAST)
    sla = 0x3c
    disp = u8g2.ssd1306_i2c_128x64_noname(id, sla)
end
Zd.setupDisplay = setupDisplay

local function showContact(name, phone)
  disp:clearBuffer()
  disp:setDrawColor(1) --/* color 1 for the box */
  -- disp:setFont(u8g2.font_6x10_tf)
  disp:setFont(u8g2.font_unifont_t_symbols)
  disp:drawStr(0, 20, name)
  disp:drawStr(0, 40, phone)
  disp:sendBuffer()
end
Zd.showContact = showContact

local function showText(body1, body2, body3)
  disp:clearBuffer()
  disp:setDrawColor(1) --/* color 1 for the box */
  -- disp:setFont(u8g2.font_6x10_tf)
  disp:setFont(u8g2.font_6x10_tf)
  if body1 ~= nil then disp:drawStr(0, 12, body1) end
  if body2 ~= nil then disp:drawStr(0, 24, body2) end
  if body3 ~= nil then disp:drawStr(0, 36, body3) end
  disp:sendBuffer()
end
Zd.showText = showText

return Zd

-- Zd.setupDisplay()
-- Zd.showContact("John Lauer", "(313) 414-7505")