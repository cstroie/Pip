-- Main file, run by init.lua, after a short delay

function unrequire(m)
  package.loaded[m] = nil
  _G[m] = nil
end

function debug(...)
  -- Print the message if the global DEBUG flag is on
  if DEBUG then print(...) end
end

-- Use ADC to read Vdd
if adc.force_init_mode(adc.INIT_VDD33) then node.restart() end
-- LCD display
lcd = require("lcd")
lcd:init()
lcd:screen(wifi.sta.gethostname(), string.gsub(wifi.sta.getmac(), ":", ""), "c")
-- Radio command
require("rcs").init()
-- NTP sync
tmr.alarm(2, 1000 * ntp_interval, tmr.ALARM_AUTO, function() require("ntp").sync() end)
-- Weather report
wx = require("wx")
-- IoT
iot = require("iot")
iot:init()
-- Temperature and humidity sensor
dht11 = require("dht11")
dht11:init()
-- Wireless
wl = require("wl")
-- PIR
pir = require("pir")
pir:init()
-- Outdoor
--outdoor = require("outdoor")

-- Rotate screens
scridx = 0

function show_screen(idx)
  local result
  print(idx, node.heap())
  if     idx == 1 then result = wl.show()
  elseif idx == 2 then result = dht11:bigtemp()
  elseif idx == 3 then result = dht11:bighmdt()
  elseif idx == 4 then result = wx:now()
  elseif idx == 4 then result = wx:today()
  elseif idx == 5 then result = wx:tomorrow()
  --elseif idx == 6 then result = wx:sun()
  --elseif idx == 7 then result = wx:moon()
  else
    result = require("clock").bigclock()
    return nil
  end
  if result == true then
    return idx + 1
  else
    return 0
  end
end

function rotate_screens()
  local nextidx
  repeat
    nextidx = show_screen(scridx)
    if nextidx == nil then
      scridx = 1
      nextidx = 1
    elseif nextidx == 0 then
      scridx = scridx + 1
    else
      scridx = nextidx
    end
  until nextidx > 0
  tmr.start(0)
end

tmr.alarm(0, 4000, tmr.ALARM_SEMI, function() rotate_screens() end)

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
