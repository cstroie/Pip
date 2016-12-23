-- Digital Clock display
local clock, module = {}, ...

require("config")

function clock.bigclock()
  -- Display a big clock
  package.loaded[module] = nil
  local result = false
  local sec, usec = rtctime.get()
  if sec ~= 0 then
    local tm = rtctime.epoch2cal(sec + TZ * 3600)
    local text = string.format("%02d:%02d", tm["hour"], tm["min"])
    result = require("bgnum").write(text, {0,4,7,9,13})
  end
  return result
end

return clock
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
