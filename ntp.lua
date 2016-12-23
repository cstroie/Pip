-- Time sync using NTP
local ntp, module = {}, ...

require("config")

function ntp.sync()
  -- Time sync using the specified server, then the gateway
  package.loaded[module] = nil
  if wifi.sta.status() == wifi.STA_GOTIP then
    sntp.sync(ntp_server,
    function(sec, usec, server)
      local tm = rtctime.epoch2cal(sec + TZ * 3600)
      debug("Time sync to " .. server .. ": " .. string.format("%04d.%02d.%02d %02d:%02d:%02d",
                                                               tm["year"], tm["mon"], tm["day"],
                                                               tm["hour"], tm["min"], tm["sec"]))
    end,
    function(errcode)
      debug("Time sync failed: " .. errcode)
      local ip, nm, gw = wifi.sta.getip()
      debug("Trying the gateway, " .. gw)
      if gw then sntp.sync(gw) end
    end)
  end
end

return ntp
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
