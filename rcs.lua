-- Radio controlled sockets on 433MHz

require("config")

local rcs = {}
rcs.SWITCHES = {0x004000, 0x010000, 0x040000, 0x100000, 0x400000}
rcs.ON  = {A = 0x000551, B = 0x001151, C = 0x001451, D = 0x001511}
rcs.OFF = {A = 0x000554, B = 0x001154, C = 0x001454, D = 0x00155f}

function rcs:send(bits)
  -- rc.send(rcs_pin, bits, rcs_bits, rcs_pl, rcs_proto, rcs_count)
  local delays = {}
  local SH, LG
  if rcs_proto == 1 then
    SH = rcs_pl
    LG = 3 * rcs_pl
  else
    SH = rcs_pl
    LG = rcs_pl
  end
  for idx = rcs_bits-1, 0, -1 do
    if bit.isset(bits, idx) then
      table.insert(delays, LG)
      table.insert(delays, SH)
    else
      table.insert(delays, SH)
      table.insert(delays, LG)
    end
  end
  table.insert(delays, SH)
  table.insert(delays, 10 * (LG + SH))
  gpio.mode(rcs_pin, gpio.OUTPUT)
  gpio.write(rcs_pin, gpio.LOW)
  gpio.serout(rcs_pin, gpio.HIGH, delays, rcs_count, 1)
  gpio.write(rcs_pin, gpio.LOW)
end

function rcs:switch(dip)
  local result = 0x00
  for k, v in ipairs(self.SWITCHES) do
    if not bit.isset(dip, k - 1) then result = result + v end
  end
  return result
end

function rcs:on(btn, dip)
  self:button(btn, "ON", dip)
end

function rcs:off(btn, dip)
  self:button(btn, "OFF", dip)
end

function rcs:button(btn, cmd, dip)
  -- Send the command to the button
  btn = btn:upper()
  cmd = cmd:upper()
  dip = dip or rcs_dip
  debug("RCS " .. btn .. ": " .. cmd)
  local code
  if rcs[cmd] and rcs[cmd][btn] then
    code = rcs[cmd][btn]
  else
    code = 0x000000
  end
  self:send(code + self:switch(dip))
end

-- Init TX
gpio.mode(rcs_pin, gpio.OUTPUT)
gpio.write(rcs_pin, gpio.LOW)

return rcs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
