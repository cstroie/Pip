-- Sync to NTP and print time

require("config")

local ntp = {}

function ntp:sync()
  if wifi.sta.status() == 5 then
    sntp.sync(ntp_server,
    function(sec, usec, server)
      if DEBUG then
        local tm = rtctime.epoch2cal(sec)
        print("Time sync to " .. server .. ": " .. string.format("%04d.%02d.%02d %02d:%02d:%02d UTC", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
      end
    end,
    function(errcode)
      if DEBUG then print("Time sync failed: " .. errcode) end
      local ip, nm, gw = wifi.sta.getip()
      if gw ~= nil then
        sntp.sync(gw)
      end
    end)
  end
end

function ntp:init()
  tmr.alarm(2, 1000 * ntp_interval, tmr.ALARM_AUTO, function() ntp:sync() end)
end

return ntp
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
