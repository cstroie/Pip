-- Radio controlled sockets on 433MHz

require("config")

local rcs = {}
rcs.sw = {0x004000, 0x010000, 0x040000, 0x100000, 0x400000}

function rcs:switch(dip)
  local result = 0x00
  for k, v in pairs(self.sw) do
    if not bit.isset(dip, k - 1) then result = result + v end
  end
  return result
end

function rcs:on(btn, dip)
  if dip == nil then dip = rcs_dip end
  local code = 0x000000
  if     btn == "A" then code = 0x000551
  elseif btn == "B" then code = 0x001151
  elseif btn == "C" then code = 0x001451
  elseif btn == "D" then code = 0x001511 end
  rc.send(rcs_pin, code + self:switch(dip), rcs_bits, rcs_pl, rcs_proto, rcs_count)
end

function rcs:off(btn, dip)
  if dip == nil then dip = rcs_dip end
  local code = 0x000000
  if     btn == "A" then code = 0x000554
  elseif btn == "B" then code = 0x001154
  elseif btn == "C" then code = 0x001454
  elseif btn == "D" then code = 0x00155f end
  rc.send(rcs_pin, code + self:switch(dip), rcs_bits, rcs_pl, rcs_proto, rcs_count)
end

function rcs:button(btn, cmd)
  btn = btn:upper()
  if DEBUG then print("RCS " .. btn .. ": " .. cmd) end
  if cmd == "on" then self:on(btn)
  elseif cmd == "off" then self:off(btn) end
end

return rcs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
