-- Radio controlled switches on 433MHz
-- Pin: 3

local rcs = {}
rcs.pin = 3
rcs.pl = 255
rcs.proto = 1
rcs.count = 4
rcs.sw = {0x004000, 0x010000, 0x040000, 0x100000, 0x400000}
rcs.dip = 0x1f

function rcs:switch(dip)
  local result = 0x00
  for k, v in pairs(self.sw) do
    if not bit.isset(dip, k - 1) then result = result + v end
  end
  return result
end

function rcs:on(btn, dip)
  if dip == nil then dip = self.dip end
  local code
  if     btn == "A" then code = 0x000551
  elseif btn == "B" then code = 0x001151
  elseif btn == "C" then code = 0x001451
  elseif btn == "D" then code = 0x001511 end
  rc.send(self.pin, code + self:switch(dip), 24, self.pl, self.proto, self.count)
end

function rcs:off(btn, dip)
  if dip == nil then dip = self.dip end
  local code
  if     btn == "A" then code = 0x000554
  elseif btn == "B" then code = 0x001154
  elseif btn == "C" then code = 0x001454
  elseif btn == "D" then code = 0x00155f end
  rc.send(self.pin, code + self:switch(dip), 24, self.pl, self.proto, self.count)
end

function rcs:button(btn, cmd)
  btn = btn:upper()
  if DEBUG then print("RCS " .. btn .. ": " .. cmd) end
  if cmd == "on" then self:on(btn)
  elseif cmd == "off" then self:off(btn) end
end

return rcs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
