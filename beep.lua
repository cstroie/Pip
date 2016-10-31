-- Beeper

require("config")
local beep = {}

function beep:onekhz()
  gpio.mode(beep_pin, gpio.OUTPUT)
  gpio.serout(beep_pin,1,{beep_pls,beep_pls},beep_rpt,1)
end

return beep
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
