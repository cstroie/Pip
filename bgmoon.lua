-- LCD big Moon phases

lcd = require("lcd")

local bgmoon = {}

function bgmoon:define(ph)
  -- Define the big Moon phases
  local xxdata = {}
  xxdata[1] = {"0003060c08181010","1f00000000000000","00180c0602030101"}
  xxdata[2] = {"0003060c08181010","1f03000000000000","00181c1e1e1f0f0f"}
  xxdata[3] = {"0003060c08181010","1f03030301010101","00181c1e1e1f1f1f"}
  xxdata[4] = {"0003060c08181010","1f07070707070707","00181c1e1e1f1f1f"}
  xxdata[5] = {"0003060c08181010","1f0f0f1f1f1f1f1f","00181c1e1e1f1f1f"}
  xxdata[6] = {"0003060c09191111","1f1f1f1f1f1f1f1f","00181c1e1e1f1f1f"}
  xxdata[7] = {"0003070f0f1f1f1f","1f1f1f1f1f1f1f1f","00181c1e1e1f1f1f"}
  xxdata[8] = {"0003070f0f1f1f1f","1f1f1f1f1f1f1f1f","00180c0612131111"}
  xxdata[9] = {"0003070f0f1f1f1f","1f1e1e1f1f1f1f1f","00180c0602030101"}
  xxdata[10]= {"0003070f0f1f1f1f","1f1c1c1c1c1c1c1c","00180c0602030101"}
  xxdata[11]= {"0003070f0f1f1f1f","1f18181810101010","00180c0602030101"}
  xxdata[12]= {"0003070f0f1f1e1e","1f18000000000000","00180c0602030101"}
  local BIG_MOON = "bgmoon" .. tostring(ph)
  if BIG_CHARS ~= BIG_MOON then
    for k,xx in ipairs(xxdata[ph]) do
      local upchar, dnchar = {}, {}
      for i=1,8 do
        local x = tonumber(string.sub(xx,i+i-1,i+i), 16)
        upchar[i] = x
        dnchar[9-i] = x
      end
      lcd:defchar(k-1, upchar)
      lcd:defchar(6-k, dnchar)
    end
    BIG_CHARS = BIG_MOON
  end
end

function bgmoon:write(phase, col)
  -- Write the moon phase at 'col'
  self:define(phase)
  lcd:bigwrite("\000\001\002", "\003\004\005", col)
end

return bgmoon
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
