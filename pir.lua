-- Motion detection

require("config")

local pir = {}

function pir.on()
  debug("Motion detected")
  if not lcd_bl then
    lcd_bl = true
    scridx = 255
  end
  tmr.start(4)
end

function pir.off()
  debug("Motion timed out")
  lcd_bl = false
end

function pir:init()
  gpio.mode(pir_pin, gpio.INT, gpio.PULLUP)
  gpio.trig(pir_pin, "up", pir.on)
end

-- Start the watchdog
tmr.alarm(4, pir_interval * 1000, tmr.ALARM_SEMI, function() pir.off() end)

return pir
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
