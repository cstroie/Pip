-- Scan and connect to WiFi

require("config")
ntp = require("ntp")
wx = require("wx")
iot = require("iot")
lcd = require("lcd")

local wl = {}
wl.check_counter = wl_tries
wl.status = {"Idle", "Connecting", "Wrong password", "AP not found", "Failed", "Connected"}

function wl:show()
  -- Display WiFi data
  local result = false
  local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
  local ip, nm, gw = wifi.sta.getip()
  if ssid and ip then
    lcd:screen(string.format("WiFi % 11s", ssid), string.format("% 16s", ip))
    result = true
  end
  debug(wifi.sta.gethostname(), ssid, wifi.sta.getrssi(), ip, nm, gw)
  return result
end

function wl:connect(ssid)
  -- Try to connect and start the watchdog
  lcd:screen("WiFi connecting", "to " .. ssid)
  wifi.sta.config(ssid, wl_ap[ssid])
  tmr.start(1)
end

function wl.scan(lst)
  -- Check the AP list for a known one
  local ap
  for ssid, v in pairs(lst) do
    authmode, rssi, bssid, channel = string.match(v, "(%d),(-?%d+),(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x),(%d+)")
    debug("  " .. ssid, rssi .. " dBm")
    if wl_ap[ssid] then ap = ssid end
  end
  if ap then
    wl:connect(ap)
  else
    debug("No known WiFi.")
    -- TODO SoftAP mode
  end
end

function wl:check()
  -- Check the WiFi connectivity and try to identify an AP
  if wifi.sta.status() ~= 5 then
    if wl.check_counter > 0 then
      lcd:screen(string.format("WiFi wait... % 3d", wl.check_counter), wl.status[wifi.sta.status()])
      wl.check_counter = wl.check_counter - 1
      tmr.start(1)
    else
      lcd:screen("WiFi scanning...", "")
      wl.check_counter = wl_tries
      wifi.setmode(wifi.STATION)
      wifi.sta.getap(wl.scan)
    end
  else
    wl.check_counter = wl_tries
    wl:show()
    ntp:sync()
    iot:connect()
  end
end

-- Start the watchdog
tmr.alarm(1, 1000, tmr.ALARM_SEMI, function() wl:check() end)

return wl
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
