-- Main file, run by init.lua, after a short delay

function debug(...)
  -- Print the message if the global DEBUG flag is on
  if DEBUG then print(...) end
end

-- Use ADC
if adc.force_init_mode(adc.INIT_ADC) then node.restart() end

-- NTP sync
ntp = require("ntp")
ntp:init()

-- Thermistor data
th = require("th")
th:init()

-- IoT
iot = require("iot")
iot:init()

-- Wireless
wl = require("wl")

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
