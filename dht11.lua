-- Get temperature and humidity using DHT11

require("config")
iot = require("iot")

local dht11 = {}

function dht11:read(pin)
  -- Read the DHT11 sensor
  local status, temp, hmdt, temp_dec, hmdt_dec = dht.read(pin or dht11_pin)
  if status == dht.OK then
    self.temp = temp
    self.hmdt = hmdt
  end
  self.status = status
end

function dht11:bigtemp()
  -- Display temperature with large LCD digits
  local result = false
  if self.temp ~= nil then
    local text = string.format("% 3d'C", self.temp)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:write(text:sub(1, 1), 0)
    bgnum:write(text:sub(2, 2), 4)
    bgnum:write(text:sub(3, 3), 8)
    bgnum:write(text:sub(4, 4), 11)
    bgnum:write(text:sub(5, 5), 13)
    unrequire("bgnum")
    result = true
  end
  return result
end

function dht11:bighmdt()
  -- Display humidity with large LCD digits
  local result = false
  if self.hmdt ~= nil then
    local text = string.format("% 3d%%", self.hmdt)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:write(text:sub(1, 1), 0)
    bgnum:write(text:sub(2, 2), 4)
    bgnum:write(text:sub(3, 3), 8)
    bgnum:write(text:sub(4, 4), 12)
    unrequire("bgnum")
    result = true
  end
  return result
end

function dht11:pub()
  -- MQTT publish telemetry data
  dht11:read()
  iot:pub("sensor/indoor/temperature", self.temp)
  iot:pub("sensor/indoor/humidity", self.hmdt)
  local root = "report/" .. NODENAME .. "/"
  iot:pub(root .. "vdd", adc.readvdd33())
  iot:pub(root .. "heap", node.heap())
  iot:pub(root .. "uptime", tmr.time())
end

function dht11:init()
  -- Initialize the timer
  tmr.alarm(3, 1000 * dht11_interval, tmr.ALARM_AUTO, function() dht11:pub() end)
end

return dht11
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
