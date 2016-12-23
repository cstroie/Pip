-- Get temperature and humidity using DHT11
local dht11, module = {}, ...

require("config")
iot = require("iot")

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
  if self.temp then
    local text = string.format("% 3d'C", self.temp)
    result = require("bgnum").write(text, {0,4,8,11,13})
  end
  return result
end

function dht11:bighmdt()
  -- Display humidity with large LCD digits
  local result = false
  if self.hmdt then
    local text = string.format("% 3d%%", self.hmdt)
    result = require("bgnum").write(text, {0,4,8,12})
  end
  return result
end

function dht11:pub()
  -- MQTT publish telemetry data
  dht11:read()
  iot:mpub({temperature = self.temp, humidity = self.hmdt}, 0, 0, "sensor/indoor/")
  iot:mpub({vdd = adc.readvdd33(), heap = node.heap(), uptime = tmr.time()}, 0, 0, "report/" .. NODENAME)
end

function dht11:init()
  -- Initialize the timer
  tmr.alarm(3, 1000 * dht11_interval, tmr.ALARM_AUTO, function() dht11:pub() end)
end

return dht11
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
