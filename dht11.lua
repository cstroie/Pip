-- Get temperature and humidity using DHT11

require("config")
lcd = require("lcd")
vdd = require("vdd")
iot = require("iot")

local dht11 = {}
dht11.temp = nil
dht11.hmdt = nil
dht11.status = nil

function dht11:read(pin)
  if pin == nil then pin = dht11_pin end
  local status, temp, hmdt, temp_dec, hmdt_dec = dht.read(pin)
  if status == dht.OK then
    self.temp = temp
    self.hmdt = hmdt
  end
  self.status = status
end

function dht11:bigtemp()
  local result = false
  if self.temp ~= nil then
    local text = string.format("% 3d'C", self.temp)
    bgnum = require("bgnum")
    bgnum:define()
    lcd:cls()
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
  local result = false
  if self.hmdt ~= nil then
    local text = string.format("% 3d%%", self.hmdt)
    bgnum = require("bgnum")
    bgnum:define()
    lcd:cls()
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
  dht11:read()
  local v = vdd.read()
  if (wifi.sta.status() == 5) and self.temp ~= nil then
    iot:pub("eridu/indoor/temperature", self.temp)
    iot:pub("eridu/indoor/humidity", self.hmdt)
    iot:pub("node/vdd", v)
    iot:pub("node/heap", node.heap())
    iot:pub("node/uptime", tmr.time())
  end
end

function dht11:init()
  --dht11:pub()
  tmr.alarm(3, 1000 * dht11_interval, tmr.ALARM_AUTO, function() dht11:pub() end)
end

return dht11
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
