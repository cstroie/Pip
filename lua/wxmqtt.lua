#!/usr/bin/lua
-- Publish weather data

-- WX data
wx_id = "ROXX0003"
wx_url = "http://wxdata.weather.com/wxdata/weather/local/" .. wx_id .. "?cc=*&unit=m&dayf=3"

-- RCS
rcs = {"a", "b", "c"}

-- Standard modules
http = require("socket.http")
socket = require("socket")
lom = require("lxp.lom")
xpath = require("xpath")

-- Sleep
function sleep(sec)
  socket.select(nil, nil, sec)
end

-- Mosquitto
local rstatus, rmodule = pcall(require, 'mosquitto')
mosquitto = rstatus and rmodule or nil

-- Weather table
wthr = {}

-- Download WX data
local response, http_code, http_headers = http.request(wx_url)

function time12to24(time)
  -- Convert time from 12 to 24 hours format
  local hours, minutes, ampm = string.match(time, "(%d+):(%d+) (%a+)")
  if ampm:upper() == "PM" then hours = hours + 12 end
  return string.format("%02d:%02d", tonumber(hours), tonumber(minutes))
end

function minutes(time)
  -- Get the minutes from 00:00
  local hours, minutes = string.match(time, "(%d+):(%d+)")
  return tonumber(hours) * 60 + tonumber(minutes)
end

-- Check http code
if http_code == 200 then
  -- Beautify
  wx_lint = response:gsub(">%s+<", "><")
  -- Parse XML
  wx_lom = lom.parse(wx_lint)
  -- Shortcut
  local xpth = xpath.selectNodes

  -- Degree °, Latin-1 176, LCD 223
  local dg = "\194\176"
  local ut = xpth(wx_lom, '/weather/head/ut/text()')[1]
  local up = xpth(wx_lom, '/weather/head/up/text()')[1]
  local dn, tc

  -- Select today/tonight
  if xpth(wx_lom, '/weather/dayf/day[1]/part[1]/t/text()')[1] == nil then
    dn = "ton"
    tc = xpth(wx_lom, '/weather/dayf/day[1]/part[2]/t/text()')[1]
  else
    dn = "tod"
    tc = xpth(wx_lom, '/weather/dayf/day[1]/part[1]/t/text()')[1]
  end

  -- Compose the response table
  -- Current weather
  wthr["now"] = xpth(wx_lom, '/weather/cc/tmp/text()')[1] .. dg .. ut .. " (" ..
                xpth(wx_lom, '/weather/cc/flik/text()')[1] .. dg .. ut .. ")" .. ", " ..
                xpth(wx_lom, '/weather/cc/t/text()')[1]
  -- Today / tonight weather
  wthr[dn] = xpth(wx_lom, '/weather/dayf/day[1]/low/text()')[1] .. "/" ..
             xpth(wx_lom, '/weather/dayf/day[1]/hi/text()')[1] .. dg .. ut .. ", " ..
             tc
  -- Tomorrow weather
  wthr["tom"] = xpth(wx_lom, '/weather/dayf/day[2]/low/text()')[1] .. "/" ..
                xpth(wx_lom, '/weather/dayf/day[2]/hi/text()')[1] .. dg .. ut .. ", " ..
                xpth(wx_lom, '/weather/dayf/day[2]/part[1]/t/text()')[1]
  -- Day after tomorrow weather
  wthr["dat"] = xpth(wx_lom, '/weather/dayf/day[3]/low/text()')[1] .. "/" ..
                xpth(wx_lom, '/weather/dayf/day[3]/hi/text()')[1] .. dg .. ut .. ", " ..
                xpth(wx_lom, '/weather/dayf/day[3]/part[1]/t/text()')[1]
  -- Athmospheric pressure
  local bar_dir = xpth(wx_lom, '/weather/cc/bar/d/text()')[1]
  if bar_dir == nil then bar_dir = "steady" end
  wthr["bar"] = xpth(wx_lom, '/weather/cc/bar/r/text()')[1] .. up .. ", " .. bar_dir
  -- Current time and time zone
  local wxtime = time12to24(xpth(wx_lom, '/weather/loc/tm/text()')[1])
  wthr["tmz"] = wxtime .. ", " ..  xpth(wx_lom, '/weather/loc/zone/text()')[1]
  -- Sunrise / Sunset
  local wxsunr = time12to24(xpth(wx_lom, '/weather/loc/sunr/text()')[1])
  local wxsuns = time12to24(xpth(wx_lom, '/weather/loc/suns/text()')[1])
  wthr["sun"] = wxsunr .. ", " .. wxsuns
  -- Moon phase
  wthr["mon"] = xpth(wx_lom, '/weather/cc/moon/icon/text()')[1] .. ", " ..
                xpth(wx_lom, '/weather/cc/moon/t/text()')[1]

  -- Lights on / off
  lights = nil
  local min_time, min_sunr, min_suns = minutes(wxtime), minutes(wxsunr), minutes(wxsuns)
  if min_time > min_sunr - 30 and min_time < min_sunr + 30 then lights = false end
  if min_time > min_suns - 30 and min_time < min_suns + 30 then lights = true end
  print("Lights", lights, minutes(wxtime), minutes(wxsunr), minutes(wxsuns))

  -- Show and count the messages to send
  for k,v in pairs(wthr) do print(k,v) end
  local mqttpubmsg = 0

  -- MQTT
  if mosquitto ~= nil then
    client = mosquitto.new()
    client.ON_CONNECT = function()
      local qos = 1
      local retain = true
      local basetopic = "wx/" .. wx_id .. "/"
      for topic, message in pairs(wthr) do
        mqttpubmsg = mqttpubmsg + 1
        client:publish(basetopic .. topic, message, qos, retain)
      end
      -- Lights
      if lights == true then
        for _, button in pairs(rcs) do
          mqttpubmsg = mqttpubmsg + 1
          client:publish("command/rcs/" .. button, "on", qos, retain)
        end
      elseif lights == false then
        for _, button in pairs(rcs) do
          mqttpubmsg = mqttpubmsg + 1
          client:publish("command/rcs/" .. button, "off", qos, retain)
        end
      end
    end

    client.ON_PUBLISH = function()
      mqttpubmsg = mqttpubmsg - 1
      if mqttpubmsg < 1 then
        client:disconnect()
      end
    end

    broker = "localhost"
    client:connect(broker)
    client:loop_forever()
  end
end

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
