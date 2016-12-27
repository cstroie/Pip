#!/usr/bin/lua
-- Post data from MQTT

-- Credentials
local ppath, pname, pext = string.match(arg[0], "(.-)([^\\/]-%.?([^%.\\/]*))$")
dofile("/etc/keys-" .. pname)

-- Standard modules
http = require("socket.http")
thingspeak = require("thingspeak")
stathat = require("stathat")
ubidots = require("ubidots")

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
    print(topic, payload)
    if     topic == "sensor/indoor/temperature" then
      thingspeak:collect("field1", payload)
      stathat.ez_value(STATHAT_KEY, "Indoor Temperature", payload)
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

    elseif topic == "sensor/outdoor/temperature" then
      --local R = 98.2/(1024/payload - 1)
      --local T = 1/(1/298.15 + math.log(R/10.63)/3986)-273.15
      --thingspeak:collect("field6", payload)
      --client:publish("sensor/outdoor/th", T)
      thingspeak:collect("field7", T)
      ubidots:collect("temperature", payload)
    elseif topic == "sensor/outdoor/dewpoint" then
      ubidots:collect("dewpoint", payload)
    elseif topic == "sensor/outdoor/humidity" then
      thingspeak:collect("field6", payload)
      ubidots:collect("humidity", payload)
    elseif topic == "sensor/outdoor/illuminance" then
      thingspeak:collect("field8", payload)
      ubidots:collect("illuminance", payload)
    elseif topic == "sensor/outdoor/sealevel" then
      ubidots:collect("pressure", payload)
    elseif topic == "report/wxstation/vdd" then
      ubidots:collect("vdd", int2float(payload, 3))
      ubidots:post("wxstation", UBIDOTS_TOKEN)
      ubidots:clear()
    end
  end

  broker = "localhost"
  client:connect(broker)
  client:loop_forever()
end
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
