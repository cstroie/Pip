-- Thermistor reading

require("config")
iot = require("iot")

local th = {cnt = 0, acc = 0, max = 5}

function th:thermo()
  -- Read the thermistor and send an average
  self.cnt = self.cnt + 1
  self.acc = self.acc + adc.read(0)
  if self.cnt >= self.max then
    iot:pub("sensor/outdoor/temperature", self.acc / self.cnt)
    iot:mpub({heap = node.heap(), uptime = tmr.time()}, 0, 0, "report/" .. NODENAME)
    self.cnt = 0
    self.acc = 0
  else
    tmr.start(3)
  end
end

function th:init()
  -- Reading timer
  tmr.register(3, 1000, tmr.ALARM_SEMI, function() th:thermo() end)
end

return th
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
