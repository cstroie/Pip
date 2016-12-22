-- Get outdoor telemetry

require("config")

local outdoor = {}

function outdoor:bigtemp()
  -- Display temperature with large LCD digits
  local result = false
  if OUT_T then
    local text = string.format("% 3d'C", OUT_T)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:bigwrite(text, {0,4,8,11,13})
    unrequire("bgnum")
    result = true
  end
  return result
end

function outdoor:bigdew()
  -- Display dewpoint with large LCD digits
  local result = false
  if OUT_D then
    local text = string.format("% 3d'C", OUT_D)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:bigwrite(text, {0,4,8,11,13})
    unrequire("bgnum")
    result = true
  end
  return result
end

function outdoor:bighmdt()
  -- Display humidity with large LCD digits
  local result = false
  if OUT_H then
    local text = string.format("% 3d%%", OUT_H)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:bigwrite(text, {0,4,8,12})
    unrequire("bgnum")
    result = true
  end
  return result
end

function outdoor:bigpress()
  -- Display pressure with large LCD digits
  local result = false
  if OUT_P then
    local text = string.format("%4d", OUT_P)
    bgnum = require("bgnum")
    bgnum:define()
    bgnum:cls()
    bgnum:bigwrite(text, {0,4,8,12})
    unrequire("bgnum")
    result = true
  end
  return result
end

return outdoor
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
