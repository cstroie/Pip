-- Digital Clock display

require("config")
lcd = require("lcd")

local clock = {}
clock.months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
clock.days = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

function clock:datetime()
  -- Display the date and time
  local result = false
  local sec, usec = rtctime.get()
  if sec ~= 0 then
    local tm = rtctime.epoch2cal(sec + timezone * 3600)
    lcd:screen(string.format("%3s, %02d %3s %04d", self.days[tm["wday"]], tm["day"], self.months[tm["mon"]], tm["year"]),
               string.format("%02d:%02d", tm["hour"], tm["min"]),
               "c")
    result = true
  end
  return result
end

function clock:bigclock()
  -- Display a big clock
  local result = false
  local sec, usec = rtctime.get()
  if sec ~= 0 then
    local tm = rtctime.epoch2cal(sec + timezone * 3600)
    local text = string.format("%02d:%02d", tm["hour"], tm["min"])
    bgnum = require("bgnum")
    bgnum:define()
    lcd:cls()
    bgnum:bigwrite(text, {0,4,7,9,13})
    unrequire("bgnum")
    result = true
  end
  return result
end

return clock
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
