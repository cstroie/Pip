-- LCD big Moon phases
local bgmoon, module = {}, ...

lcd = require("lcd")

function bgmoon.write(phase, col)
  -- Write the moon phase at 'col'
  package.loaded[module] = nil
  local BIG_MOON = "bgmoon" .. tostring(phase)
  -- Define the big Moon phases
  if BIG_CHARS ~= BIG_MOON then
    local data = {}
    data[1] = {"0003060c08181010","1f00000000000000","00180c0602030101"}
    data[2] = {"0003060c08181010","1f03000000000000","00181c1e1e1f0f0f"}
    data[3] = {"0003060c08181010","1f03030301010101","00181c1e1e1f1f1f"}
    data[4] = {"0003060c08181010","1f07070707070707","00181c1e1e1f1f1f"}
    data[5] = {"0003060c08181010","1f0f0f1f1f1f1f1f","00181c1e1e1f1f1f"}
    data[6] = {"0003060c09191111","1f1f1f1f1f1f1f1f","00181c1e1e1f1f1f"}
    data[7] = {"0003070f0f1f1f1f","1f1f1f1f1f1f1f1f","00181c1e1e1f1f1f"}
    data[8] = {"0003070f0f1f1f1f","1f1f1f1f1f1f1f1f","00180c0612131111"}
    data[9] = {"0003070f0f1f1f1f","1f1e1e1f1f1f1f1f","00180c0602030101"}
    data[10]= {"0003070f0f1f1f1f","1f1c1c1c1c1c1c1c","00180c0602030101"}
    data[11]= {"0003070f0f1f1f1f","1f18181810101010","00180c0602030101"}
    data[12]= {"0003070f0f1f1e1e","1f18000000000000","00180c0602030101"}
    for k,xx in ipairs(data[phase]) do
      local revxx = ""
      for i=8,1,-1 do revxx = revxx .. string.sub(xx,i+i-1,i+i) end
      lcd:defchar(k-1, xx)
      lcd:defchar(k+2, revxx)
    end
    BIG_CHARS = BIG_MOON
  end
  lcd:bigwrite("\000\001\002", "\003\004\005", col)
  return true
end

return bgmoon
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
