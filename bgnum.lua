-- LCD big numbers

lcd = require("lcd")

local bgnum = {}

function bgnum:define()
  if BIG_CHARS ~= "bgnum" then
    lcd:defchar(0, {0x1f,0x1f,0x1f,0x00,0x00,0x00,0x00,0x00})
    lcd:defchar(1, {0x00,0x00,0x00,0x00,0x00,0x1f,0x1f,0x1f})
    lcd:defchar(2, {0x1f,0x1f,0x00,0x00,0x00,0x00,0x1f,0x1f})
    lcd:defchar(3, {0x1f,0x1f,0x00,0x00,0x00,0x00,0x00,0x00})
    lcd:defchar(4, {0x00,0x00,0x00,0x00,0x00,0x00,0x1f,0x1f})
    lcd:defchar(5, {0x00,0x00,0x01,0x03,0x03,0x01,0x00,0x00})
    lcd:defchar(6, {0x00,0x00,0x10,0x18,0x18,0x10,0x00,0x00})
    lcd:defchar(7, {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00})
    BIG_CHARS = "bgnum"
  end
end

function bgnum:write(digit, col)
  if (digit == "0") then
    lcd:bigwrite({255,3,255}, {255,4,255}, col)
  elseif (digit == "1") then
    lcd:bigwrite({0,255,32}, {1,255,1}, col)
  elseif (digit == "2") then
    lcd:bigwrite({0,2,255}, {255,4,1}, col)
  elseif (digit == "3") then
    lcd:bigwrite({0,2,255}, {1,4,255}, col)
  elseif (digit == "4") then
    lcd:bigwrite({255,4,255}, {32,32,255}, col)
  elseif (digit == "5") then
    lcd:bigwrite({255,2,0}, {1,4,255}, col)
  elseif (digit == "6") then
    lcd:bigwrite({255,2,0}, {255,4,255}, col)
  elseif (digit == "7") then
    lcd:bigwrite({0,3,255}, {32,32,255}, col)
  elseif (digit == "8") then
    lcd:bigwrite({255,2,255}, {255,4,255}, col)
  elseif (digit == "9") then
    lcd:bigwrite({255,2,255}, {1,4,255}, col)
  elseif (digit == "C") then
    lcd:bigwrite({255,3,0}, {255,4,1}, col)
  elseif (digit == ":") then
    lcd:bigwrite({5,6}, {5,6}, col)
  elseif (digit == ".") then
    lcd:bigwrite({32,32}, {5,6}, col)
  elseif (digit == "'") then
    lcd:bigwrite({5,6}, {32,32}, col)
  elseif (digit == "%") then
    lcd:bigwrite({5,6,1,0}, {1,0,5,6}, col)
  elseif (digit == "-") then
    lcd:bigwrite({32,1,1}, {32,32,32}, col)
  elseif (digit == " ") then
    lcd:bigwrite({32,32,32}, {32,32,32}, col)
  end
end

return bgnum
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
