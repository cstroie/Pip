#!/usr/bin/lua
-- Post data from MQTT

-- Credentials
local ppath, pname, pext = string.match(arg[0], "(.-)([^\\/]-%.?([^%.\\/]*))$")
dofile("/etc/keys-" .. pname)

-- Standard modules
http = require("socket.http")
thingspeak = require("thingspeak")
stathat = require("stathat")

-- Mosquitto
local rstatus, rmodule = pcall(require, 'mosquitto')
mosquitto = rstatus and rmodule or nil

-- MQTT
if mosquitto ~= nil then
  client = mosquitto.new()
  client.ON_CONNECT = function()
    client:subscribe("#", 0)
  end

  client.ON_MESSAGE = function(mid, topic, payload)
    print(topic, payload)
    if     topic == "sensor/indoor/temperature" then
      thingspeak:collect("field1", payload)
      stathat.ez_value(STATHAT_KEY, "Indoor Temperature", payload)
    elseif topic == "sensor/outdoor/temperature" then
      local R = 98.2/(1024/payload - 1)
      local T = 1/(1/298.15 + math.log(R/10.63)/3986)-273.15
      thingspeak:collect("field6", payload)
      thingspeak:collect("field7", T)
      client:publish("sensor/outdoor/th", T)
    elseif topic == "sensor/indoor/humidity" then
      thingspeak:collect("field2", payload)
      stathat.ez_value(STATHAT_KEY, "Indoor Humidity", payload);
    elseif topic == "report/pip/vdd" then
      thingspeak:collect("field3", payload)
    elseif topic == "report/pip/heap" then
      thingspeak:collect("field4", payload)
    elseif topic == "report/pip/uptime" then
      thingspeak:collect("field5", payload)
      thingspeak:post(THINGSPEAK_KEY)
      thingspeak:clear()
    elseif topic == "report/pop/uptime" then
      thingspeak:collect("status", "POP: " .. payload)
    end
  end

  broker = "localhost"
  client:connect(broker)
  client:loop_forever()
end
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
