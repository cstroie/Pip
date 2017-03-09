#!/usr/bin/lua
-- Post data from MQTT

-- Credentials
local ppath, pname, pext = string.match(arg[0], "(.-)([^\\/]-%.?([^%.\\/]*))$")
dofile("/etc/keys-" .. pname)

-- Standard modules
http = require("socket.http")
ts_wxmon = require("thingspeak")
ts_wxsta = require("thingspeak")
ts_nano = require("thingspeak")
aprs = require("aprs")
zambretti = require("zambretti")

-- Mosquitto
local rstatus, rmodule = pcall(require, 'mosquitto')
mosquitto = rstatus and rmodule or nil

function int2float(x, pr)
  -- Convert integer to "float" with specified precision
  local result
  if pr == 2 then
    result = string.format("%d.%02d", math.floor(x/100), math.floor(x%100))
  elseif pr == 3 then
    result = string.format("%d.%03d", math.floor(x/1000), math.floor(x%1000))
  else
    result = string.format("%d.%02d", x, 0)
  end
  return result
end

-- MQTT
if mosquitto ~= nil then
  client = mosquitto.new()
  client.ON_CONNECT = function()
    client:subscribe("#", 0)
  end

  client.ON_MESSAGE = function(mid, topic, payload)
    local value = tonumber(payload)
    if value == nil then
      return
    end

    print(topic, value)

    -- WxMonitor
    if     topic == "sensor/indoor/temperature" then
      ts_wxmon:collect("field1", value)
    elseif topic == "sensor/indoor/humidity" then
      ts_wxmon:collect("field2", value)
    elseif topic == "report/wxmon/vcc" then
      ts_wxmon:collect("field3", value)
    elseif topic == "report/wxmon/heap" then
      ts_wxmon:collect("field4", value)
    elseif topic == "report/wxmon/uptime" then
      ts_wxmon:collect("field5", value)
    elseif topic == "report/wxmon/wifi/rssi" then
      ts_wxmon:collect("field6", value)
      ts_wxmon:post(TS_WXMON_KEY)
      ts_wxmon:clear()

    -- WxStation
    elseif topic == "sensor/outdoor/temperature" then
      --local R = 98.2/(1024/payload - 1)
      --local T = 1/(1/298.15 + math.log(R/10.63)/3986)-273.15
      ts_wxsta:collect("field1", value)
      aprs:collect("temp", value)
    elseif topic == "sensor/outdoor/humidity" then
      ts_wxsta:collect("field2", value)
      aprs:collect("hmdt", value)
    elseif topic == "sensor/outdoor/dewpoint" then
      ts_wxsta:collect("field3", value)
      aprs:collect("dewp", value)
    elseif topic == "sensor/outdoor/sealevel" then
      ts_wxsta:collect("field4", value)
      ts_wxsta:collect("status", zambretti:weather(value, 3600))
      aprs:collect("pres", value)
    elseif topic == "sensor/outdoor/illuminance" then
      ts_wxsta:collect("field5", value)
      aprs:collect("lux", value)
    elseif topic == "sensor/outdoor/visible" then
      ts_wxsta:collect("field6", value)
      aprs:collect("visb", value)
    elseif topic == "sensor/outdoor/infrared" then
      ts_wxsta:collect("field7", value)
      aprs:collect("ired", value)
    elseif topic == "report/wxsta/heap" then
      aprs:collect("heap", value)
    elseif topic == "report/wxsta/wifi/rssi" then
      ts_wxsta:collect("field8", value)
      ts_wxsta:post(TS_WXSTA_KEY)
      ts_wxsta:clear()
      aprs:collect("rssi", value)
    elseif topic == "report/wxsta/vcc" then
      aprs:collect("vcc", value)
      aprs:post()
      aprs:clear()

    -- Nano
    elseif topic == "sensor/nano/temperature" then
      ts_nano:collect("field1", value)
    elseif topic == "sensor/nano/thermistor" then
      ts_nano:collect("field2", value)
      ts_nano:post(TS_NANO_KEY)
      ts_nano:clear()
    end
  end

  broker = "localhost"
  client:connect(broker)
  client:loop_forever()
end
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
