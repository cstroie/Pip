-- Read the battery voltage

lcd = require("lcd")

local vdd = {}

function vdd:read()
  return adc.readvdd33()
end

function vdd:show()
  local result = false
  local v = self:read()
--  if v ~= 65535 then
    lcd:screen("Vdd:  " .. v .. " mV", "Heap: " .. node.heap() .. " bytes")
    result = true
--  end
  return result
end

return vdd
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
