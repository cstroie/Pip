#!/usr/bin/lua
-- Post data from MQTT

-- Credentials
local ppath, pname, pext = string.match(arg[0], "(.-)([^\\/]-%.?([^%.\\/]*))$")
dofile(os.getenv("HOME") .. "/.keys-" .. pname)

-- Standard modules
http = require("socket.http")
stathat = require("stathat")

-- Mosquitto
local rstatus, rmodule = pcall(require, 'mosquitto')
mosquitto = rstatus and rmodule or nil

-- ThingSpeak, SparkFun, StatHat
ts = {api_key = THINGSPEAK_KEY}
sf = {private_key = SPARKFUN_KEY}
stathat_key = STATHAT_KEY

-- MQTT
if mosquitto ~= nil then
  client = mosquitto.new()
  client.ON_CONNECT = function()
    client:subscribe("#", 0)
  end

  client.ON_MESSAGE = function(mid, topic, payload)
    print(topic, payload)
    if     topic == "sensor/indoor/temperature" then
      ts["field1"] = payload
      sf["temp"] = payload
      stathat.ez_value(stathat_key, "Indoor Temperature", payload);
    elseif topic == "sensor/outdoor/temperature" then
      ts["field6"] = payload
      local r = 98.2/(1024/payload - 1)
      t = 1/(1/298.15 + math.log(r/10.63)/3986)-273.15
      ts["field7"] = t
      --sf["temp"] = payload
    elseif topic == "sensor/indoor/humidity" then
      ts["field2"] = payload
      sf["hmdt"] = payload
      stathat.ez_value(stathat_key, "Indoor Humidity", payload);
    elseif topic == "report/pip/vdd" then
      ts["field3"] = payload
      sf["vdd"] = payload
    elseif topic == "report/pip/heap" then
      ts["field4"] = payload
      sf["heap"] = payload
    elseif topic == "report/pip/uptime" then
      ts["field5"] = payload
      sf["uptime"] = payload
      -- ThingSpeak
      tsbody = ""
      for k,v in pairs(ts) do tsbody = tsbody .. "&" .. k .. "=" .. v end
      --print(tsbody:sub(2))
      local rspbody, rspcode, rsphdrs = http.request("https://api.thingspeak.com/update", tsbody:sub(2))
      --print(rspbody, rspcode, rsphdrs)
      -- SparkFun
      sfbody = ""
      for k,v in pairs(sf) do sfbody = sfbody .. "&" .. k .. "=" .. v end
      local rspbody, rspcode, rsphdrs = http.request("https://data.sparkfun.com/input/" .. SPARKFUN_PUBKEY .. "?" .. sfbody:sub(2))
    end
  end

  broker = "localhost"
  client:connect(broker)
  client:loop_forever()
end
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
