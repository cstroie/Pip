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
  local result = false
  local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
  local ip, nm, gw = wifi.sta.getip()
  if (ssid ~= nil) and (ip ~= nil) then
    lcd:screen(string.format("WiFi % 11s", ssid), string.format("% 16s", ip))
    result = true
  end
  if DEBUG then print(wifi.sta.gethostname(), ip, nm, gw) end
  return result
end

function wl:connect(ssid)
  if DEBUG then print("Connecting to " .. ssid .. " ...") end
  lcd:screen("WiFi connecting", "to " .. ssid)
  wifi.sta.config(ssid, wl_ap[ssid])
  tmr.start(1)
end

function wl.scan(lst)
  local ap
  if DEBUG then print("Scanning for WiFi hotspots...") end
  for ssid, v in pairs(lst) do
    authmode, rssi, bssid, channel = string.match(v, "(%d),(-?%d+),(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x),(%d+)")
    if DEBUG then print("  " .. ssid, rssi .. " dBm") end
    if wl_ap[ssid] ~= nil then ap = ssid end
  end
  if ap ~= nil then
    wl:connect(ap)
  else
    if DEBUG then print("No known WiFi.") end
    -- TODO SoftAP mode
  end
end

function wl:check()
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

tmr.alarm(1, 1000, tmr.ALARM_SEMI, function() wl:check() end)

return wl
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
