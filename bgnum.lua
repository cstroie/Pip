-- LCD big numbers and symbols

lcd = require("lcd")

local bgnum = {}

function bgnum:cls()
  -- Wrapper
  lcd:cls()
end

function bgnum:define()
  -- Define the big digits
  if BIG_CHARS ~= "bgnum" then
    lcd:defchar(0, "1f1f1f0000000000")
    lcd:defchar(1, "00000000001f1f1f")
    lcd:defchar(2, "1f1f000000001f1f")
    lcd:defchar(3, "1f1f000000000000")
    lcd:defchar(4, "0000000000001f1f")
    lcd:defchar(5, "0000010303010000")
    lcd:defchar(6, "0000101818100000")
    lcd:defchar(7, "0000000000000000")
    BIG_CHARS = "bgnum"
  end
end

function bgnum:write(digit, col)
  -- Write the digit at 'col'
  if     digit == "0" then lcd:bigwrite("\255\003\255", "\255\004\255", col)
  elseif digit == "1" then lcd:bigwrite("\000\255\032", "\001\255\001", col)
  elseif digit == "2" then lcd:bigwrite("\000\002\255", "\255\004\001", col)
  elseif digit == "3" then lcd:bigwrite("\000\002\255", "\001\004\255", col)
  elseif digit == "4" then lcd:bigwrite("\255\004\255", "\032\032\255", col)
  elseif digit == "5" then lcd:bigwrite("\255\002\000", "\001\004\255", col)
  elseif digit == "6" then lcd:bigwrite("\255\002\000", "\255\004\255", col)
  elseif digit == "7" then lcd:bigwrite("\000\003\255", "\032\032\255", col)
  elseif digit == "8" then lcd:bigwrite("\255\002\255", "\255\004\255", col)
  elseif digit == "9" then lcd:bigwrite("\255\002\255", "\001\004\255", col)
  elseif digit == "C" then lcd:bigwrite("\255\003\000", "\255\004\001", col)
  elseif digit == "-" then lcd:bigwrite("\032\001\001", "\032\032\032", col)
  elseif digit == " " then lcd:bigwrite("\032\032\032", "\032\032\032", col)
  elseif digit == ":" then lcd:bigwrite("\005\006", "\005\006", col)
  elseif digit == "." then lcd:bigwrite("\032\032", "\005\006", col)
  elseif digit == "'" then lcd:bigwrite("\005\006", "\032\032", col)
  elseif digit == "%" then lcd:bigwrite("\005\006\001\000", "\001\000\005\006", col)
  end
end

function bgnum:bigwrite(text, cols)
  -- Write the text, big, at columns 'cols'
  for idx,col in ipairs(cols) do
    self:write(text:sub(idx, idx), col)
  end
end

return bgnum
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
