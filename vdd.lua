-- Read the battery voltage

lcd = require("lcd")

local vdd = {}

function vdd:show()
  local result = false
--  if v ~= 65535 then
    lcd:screen("Vdd:  " .. adc.readvdd33() .. " mV", "Heap: " .. node.heap() .. " bytes")
    result = true
--  end
  return result
end

return vdd
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
