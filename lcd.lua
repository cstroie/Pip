-- HD44780 i2c 4 bit driver

require("config")

local lcd = {}
local RS = 0x01  -- Register selector
local EN = 0x04  -- Write Enable
local BL = 0x08  -- BackLight

function lcd:send(reg, data)
  -- reg: register 0 - instruction, 1 - data (default)
  -- data: table
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
  if onoff == "on" then
    lcd_bl = true
  else
    lcd_bl = false
  end
  lcd:send(0, {0x00})
end

function lcd:cls()
  lcd:send(0, {0x01})
end

function lcd:home()
  lcd:send(0, {0x02})
end

function lcd:cursor(onoff, style)
  if (onoff == 0) then
    lcd:send(0, {0x0c})
  else
    if (style == 0) then
      lcd:send(0, {0x0e})
    else
      lcd:send(0, {0x0f})
    end
  end
end

function lcd:linecol(line, col)
  if (line == 2) then
    lcd:send(0, {0xc0 + bit.band(col, 0x0f)})
  elseif (line == 1) then
    lcd:send(0, {0x80 + bit.band(col, 0x0f)})
  end
end

function lcd:write(text, line, col)
  lcd:linecol(line, col)
  if (type(text) == "table") then
    lcd:send(1, text)
  else
    if (type(text) == "number") then text = tostring(text) end
    local data = {}
    text:gsub(".", function(c) table.insert(data, c:byte()) end)
    lcd:send(1, data)
  end
end

function lcd:writeline(text, line, align)
  local col = 0
  if text ~= nil then
    if DEBUG then print("LCD" .. line .. ": " .. text) end
    if align == "c" and #text < 16 then
      col = (16 - #text) / 2
    end
    lcd:write(text, line, col)
  end
end

function lcd:screen(line1, line2, align)
  lcd:cls()
  lcd:writeline(line1, 1, align)
  lcd:writeline(line2, 2, align)
end

function lcd:defchar(num, data)
  -- num: char number 0-7
  -- data: table 8 lines x 5 bits
  lcd:send(0, {0x40 + 8 * num})
  lcd:send(1, data)
end

function lcd:bigwrite(uprow, btrow, col)
  lcd:write(uprow, 1, col)
  lcd:write(btrow, 2, col)
end

function lcd:init()
  i2c.setup(lcd_id, lcd_sda, lcd_scl, i2c.SLOW)
  lcd:send(0, {0x33,0x32,0x28,0x0c,0x06})
end

return lcd
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
