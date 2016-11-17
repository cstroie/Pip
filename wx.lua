-- Weather report from MQTT "wx/STATION/now|tod|tom..." "line1, line2"

require("config")
lcd = require("lcd")

local wx = {}
wx.wthr = {}

function wx:weather(id, msg)
  msg = msg:gsub("\194\176", "\223")  -- UTF8
  msg = msg:gsub("\176", "\223")      -- Latin1
  local ln1, ln2 = string.match(msg, '^(.*), (.*)$')
  self.wthr[id] = {ln1 = ln1, ln2 = ln2}
  if     id == "ton" then self.wthr["tod"] = nil
  elseif id == "tod" then self.wthr["ton"] = nil
  elseif id == "tmz" then timezone = tonumber(ln2) end
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
    local ph
    local wxph = tonumber(self.wthr.mon.ln1)
    if     wxph < 2  then ph = 1
    elseif wxph < 4  then ph = 2
    elseif wxph < 6  then ph = 3
    elseif wxph < 9  then ph = 4
    elseif wxph < 11 then ph = 5
    elseif wxph < 13 then ph = 6
    elseif wxph < 16 then ph = 7
    elseif wxph < 18 then ph = 8
    elseif wxph < 20 then ph = 9
    elseif wxph < 23 then ph = 10
    elseif wxph < 25 then ph = 11
    elseif wxph < 27 then ph = 12
    else ph = 1
    end
    local w1, w2 = string.match(self.wthr.mon.ln2, '^(.*) (.*)$')
    if not w1 then
      w1 = self.wthr.mon.ln2
      w2 = "Moon"
    end
    lcd:screen(w1, w2)
    bgmoon = require("bgmoon")
    bgmoon:write(ph, 12)
    unrequire("bgmoon")
    result = true
  end
  return result
end

return wx
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
