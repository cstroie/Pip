-- Weather report from MQTT "wx/STATION/now|tod|tom..." "line1, line2"

require("config")
lcd = require("lcd")

local wx = {}
wx.wthr = {}

function wx:weather(id, msg)
  msg = msg:gsub("\176", "\223")
  local ln1, ln2 = string.match(msg, '^(.*), (.*)$')
  self.wthr[id] = {ln1 = ln1, ln2 = ln2}
  if     id == "ton" then self.wthr["tod"] = nil
  elseif id == "tod" then self.wthr["ton"] = nil
  elseif id == "tmz" then timezone = ln2 end
end

function wx:now()
  local result = false
  if self.wthr.now then
    lcd:screen(string.format("Now% 13s", self.wthr.now.ln1), self.wthr.now.ln2)
    result = true
  end
  return result
end

function wx:today()
  local result = false
  if self.wthr.tod then
    lcd:screen(string.format("Today  % 9s", self.wthr.tod.ln1), self.wthr.tod.ln2)
    result = true
  elseif self.wthr.ton then
    lcd:screen(string.format("Tonight% 9s", self.wthr.ton.ln1), self.wthr.ton.ln2)
    result = true
  end
  return result
end

function wx:tomorrow()
  local result = false
  if self.wthr.tom then
    lcd:screen(string.format("Tmrrow % 9s", self.wthr.tom.ln1), self.wthr.tom.ln2)
    result = true
  end
  return result
end

function wx:baro()
  local result = false
  if self.wthr.bar then
    lcd:screen(string.format("Baro% 12s", self.wthr.bar.ln1), self.wthr.bar.ln2)
    result = true
  end
  return result
end

function wx:sun()
  local result = false
  if self.wthr.sun then
    lcd:screen(string.format("Sunrise % 8s", self.wthr.sun.ln1), string.format("Sunset  % 8s", self.wthr.sun.ln2))
    result = true
  end
  return result
end

function wx:moon()
  local result = false
  if self.wthr.mon then
    local full = (tonumber(self.wthr.mon.ln1) + 2) / 4
    lcd:screen("Moon   [" .. string.rep("\095", 7 - full) .. string.rep("\255", full) .. "]", self.wthr.mon.ln2)
    result = true
  end
  return result
end

return wx
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
