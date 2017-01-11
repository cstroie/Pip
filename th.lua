-- Thermistor reading

require("config")
iot = require("iot")

local th = {cnt = 0, acc = 0, max = 5}

function th:thermo()
  -- Read the thermistor and send an average
  self.cnt = self.cnt + 1
  self.acc = self.acc + adc.read(0)
  debug("Thermistor reading " .. self.cnt, self.acc)
  if self.cnt >= self.max then
    iot:pub("sensor/outdoor/thermistor", self.acc / self.cnt)
<<<<<<< HEAD
    iot:mpub({heap = node.heap(), uptime = tmr.time()}, 0, 0, "report/" .. NODENAME)
=======
    iot:mpub({heap = node.heap(),
              rssi = wifi.sta.getrssi(),
              uptime = tmr.time()},
              0, 0, "report/" .. NODENAME:lower())
>>>>>>> 26e07fa4f2a150d9a66fbeb46d77f021e688a45d
    self.cnt = 0
    self.acc = 0
    tmr.interval(3, 1000 * CFG.TH.interval)
  else
    tmr.interval(3, 1000)
  end
  tmr.start(3)
end

function th:init()
  -- Reading timer
  tmr.alarm(3, 1000 * CFG.TH.interval, tmr.ALARM_SEMI, function() th:thermo() end)
end

return th
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
