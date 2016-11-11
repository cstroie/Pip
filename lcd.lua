-- HD44780 i2c 4 bit driver

require("config")

local lcd = {}
local RS = 0x01  -- Register selector
local EN = 0x04  -- Write Enable
local BL = 0x08  -- BackLight

local ROWS, COLS = 2, 16
local LNADDR = {0x00, 0x40, 0x14, 0x54}
local LNADDR = {0x80, 0xc0}

function lcd:send(reg, data)
  -- Send the bitstream
  -- reg: register 0 - instruction, 1 - data (default)
  -- data: table of bytes to send
  local i, byte, ub, lb
  local stream = {}
  local bl = lcd_bl and BL or 0x00
  if reg ~= 1 then reg = 0 end
  local rs = bit.band(RS, reg)
  for i, byte in pairs(data) do
    ub = bit.band(byte, 0xf0) + bl + rs
    lb = bit.lshift(bit.band(byte, 0x0f), 4) + bl + rs
    table.insert(stream, ub + EN)
    table.insert(stream, ub)
    table.insert(stream, lb + EN)
    table.insert(stream, lb)
  end
  i2c.start(lcd_id)
  i2c.address(lcd_id, lcd_dev, i2c.TRANSMITTER)
  i2c.write(lcd_id, stream)
  i2c.stop(lcd_id)
end

function lcd:light(onoff)
  -- Turm on/off the LCD backlight
  lcd_bl = onoff == "on" and true or false
  lcd:send(0, {0x00})
end

function lcd:cls()
  -- Clear and go home
  lcd:send(0, {0x01})
end

function lcd:home()
  -- Go home
  lcd:send(0, {0x02})
end

function lcd:cursor(onoff, style)
  -- Set the cursor style
  -- off:   cursor(false)
  -- line:  cursor(true)
  -- block: cursor(true, true)
  if not onoff then
    lcd:send(0, {0x08})
  else
    if style then
      lcd:send(0, {0x0d})
    else
      lcd:send(0, {0x0e})
    end
  end
end

function lcd:write(text, line, col)
  -- Set the address and send the bytestream to write
  lcd:send(0, {LNADDR[line] + col})
  if type(text) == "table" then
    lcd:send(1, text)
  else
    text = (type(text) == "number") and tostring(text) or text
    local data = {}
    text:gsub(".", function(c) table.insert(data, c:byte()) end)
    lcd:send(1, data)
  end
end

function lcd:writeline(text, line, align)
  -- Write the specified line, aligned
  local col = 0
  if text ~= nil then
    if DEBUG then print("LCD" .. line .. ": " .. text) end
    if align == "c" and #text < COLS then
      col = (COLS - #text) / 2
    elseif align == "r" and #text < COLS then
      col = COLS - #text
    end
    lcd:write(text, line, col)
  end
end

function lcd:screen(line1, line2, align1, align2)
  -- Write the two lines on the display, aligned
  align2 = align2 or align1
  lcd:cls()
  lcd:writeline(line1, 1, align1)
  lcd:writeline(line2, 2, align2)
end

function lcd:defchar(num, hexdata)
  -- Define a big character
  -- num: char number 0-7
  -- data: table 8 lines x 5 bits
  local data = {}
  for i=1,8 do data[i] = tonumber(string.sub(hexdata, i+i-1, i+i), 16) end
  lcd:send(0, {0x40 + 8 * num})
  lcd:send(1, data)
end

function lcd:bigwrite(uprow, btrow, col)
  -- Write a big character at 'col'
  lcd:write(uprow, 1, col)
  lcd:write(btrow, 2, col)
end

function lcd:init()
  -- Init the LCD (tested on 2x16)
  i2c.setup(lcd_id, lcd_sda, lcd_scl, i2c.SLOW)
  lcd:send(0, {0x33,0x32,0x28,0x0c,0x06})
end

return lcd
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
