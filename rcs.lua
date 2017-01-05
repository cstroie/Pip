-- Radio controlled sockets on 433MHz
local rcs, module = {}, ...

require("config")

rcs.SWITCHES = {0x004000, 0x010000, 0x040000, 0x100000, 0x400000}
rcs.ON  = {A = 0x000551, B = 0x001151, C = 0x001451, D = 0x001511}
rcs.OFF = {A = 0x000554, B = 0x001154, C = 0x001454, D = 0x00155f}

function rcs.button(btn, cmd, dip)
  -- Send the command to the button
  package.loaded[module] = nil
  btn = btn:upper()
  cmd = cmd:upper()
  dip = dip or rcs_dip
  debug("RCS " .. btn .. ": " .. cmd)
  if cmd == "ON" or cmd == "OFF" then
    if btn == "ALL" then
      for k,v in pairs(rcs[cmd]) do rcs.button(k, cmd, dip) end
    else
      -- DIP switches
      local dip_code = 0x00
      for k, v in ipairs(rcs.SWITCHES) do
        if not bit.isset(dip, k - 1) then dip_code = dip_code + v end
      end
      -- Code
      local code = rcs[cmd][btn]
      if code then
        rc.send(rcs_pin, code + dip_code, rcs_bits, rcs_pl, rcs_proto, rcs_count)
        --rfswitch.send(rcs_proto, rcs_pl, rcs_count, rcs_pin, code + dip_code, rcs_bits)
      end
    end
  end
end

function rcs.init()
  -- Init TX
  package.loaded[module] = nil
  gpio.mode(rcs_pin, gpio.OUTPUT)
  gpio.write(rcs_pin, gpio.LOW)
end

return rcs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
