#!/usr/bin/lua
-- Post data from MQTT

require("config")

-- Standard modules
http = require("socket.http")

-- Mosquitto
local rstatus, rmodule = pcall(require, 'mosquitto')
mosquitto = rstatus and rmodule or nil

-- ThingSpeak
ts = {["api_key"] = ts_wkey}
sf = {["private_key"] = sf_pvkey}

-- MQTT
if mosquitto ~= nil then
  client = mosquitto.new()
  client.ON_CONNECT = function()
    client:subscribe("#", 0)
  end

  client.ON_MESSAGE = function(mid, topic, payload)
    --print(topic, payload)
    if     topic == "eridu/indoor/temperature" then
      ts["field1"] = payload
      sf["temp"] = payload
    elseif topic == "eridu/indoor/humidity" then
      ts["field2"] = payload
      sf["hmdt"] = payload
    elseif topic == "node/vdd" then
      ts["field3"] = payload
      sf["vdd"] = payload
    elseif topic == "node/heap" then
      ts["field4"] = payload
      sf["heap"] = payload
    elseif topic == "node/uptime" then
      ts["field5"] = payload
      sf["uptime"] = payload
      -- ThingSpean
      tsbody = ""
      for k,v in pairs(ts) do tsbody = tsbody .. "&" .. k .. "=" .. v end
      local rspbody, rspcode, rsphdrs = http.request("https://api.thingspeak.com/update", tsbody:sub(2))
      -- SparkFun
      sfbody = ""
      for k,v in pairs(sf) do sfbody = sfbody .. "&" .. k .. "=" .. v end
      local rspbody, rspcode, rsphdrs = http.request("https://data.sparkfun.com/input/" .. sf_pbkey .. "?" .. sfbody:sub(2))
    end
  end

  broker = "localhost"
  client:connect(broker)
  client:loop_forever()
end
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
