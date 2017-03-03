-- Zambretti forecaster
-- Copyright 2017 Costin STROIE <costinstroie@eridu.eu.org>
-- Based on beteljuice.com - near enough Zambretti Algorhithm

module(..., package.seeall);

local zambretti = {}

zambretti.BARO_TOP  = 1050
zambretti.BARO_BOT  = 950
zambretti.THRESHOLD = 0.3
zambretti.MAXCOUNT  = 60
zambretti.COUNTER   = 0
zambretti.PREVIOUS  = nil

zambretti.FORECAST = {"Settled fine", "Fine weather", "Becoming fine",
            "Fine, becoming less settled", "Fine, possible showers",
            "Fairly fine, improving", "Fairly fine, possible showers early",
            "Fairly fine, showery later", "Showery early, improving",
            "Changeable, mending", "Fairly fine, showers likely",
            "Rather unsettled clearing later",
            "Unsettled, probably improving", "Showery, bright intervals",
            "Showery, becoming less settled", "Changeable, some rain",
            "Unsettled, short fine intervals", "Unsettled, rain later",
            "Unsettled, some rain", "Mostly very unsettled",
            "Occasional rain, worsening", "Rain at times, very unsettled",
            "Rain at frequent intervals", "Rain, very unsettled",
            "Stormy, may improve", "Stormy, much rain"}
zambretti.RISING  = {26,26,26,25,25,20,17,13,12,10, 9, 7, 6, 3, 2, 2, 1, 1, 1, 1, 1, 1}
zambretti.STEADY  = {26,26,26,26,26,26,24,24,23,19,16,14,11, 5, 2, 2, 1, 1, 1, 1, 1, 1}
zambretti.FALLING = {26,26,26,26,26,26,26,26,24,24,22,21,18,15, 8, 4, 2, 2, 2, 1, 1, 1}


function zambretti:weather(value, maxcount)
  local result
  if maxcount == nil then
    maxcount = self.MAXCOUNT
  end
  if self.PREVIOUS == nil then
    self.PREVIOUS = value
  end
  self.COUNTER = self.COUNTER + 1
  if self.COUNTER >= maxcount then
    result = self:forecast(value, self.PREVIOUS)
    self.COUNTER = 0
    self.PREVIOUS = value
  end
  if result ~= nil then
    print("Zambretti: " .. result)
  end
  return result
end


function zambretti:forecast(current, previous, trend, month, bottom, top)
  -- Need to specify 'current' and 'previous' or 'trend'
  local hpa = current
  if month == nil then month = tonumber(os.date("%m")) end
  if bottom == nil then bottom = self.BARO_BOT end
  if top == nil then top = self.BARO_TOP end
  if previous == nil then
    if trend == nil then
      trend = 0
    end
  elseif current > previous and current - previous > self.THRESHOLD then
    trend = 1
  elseif current < previous and previous - current > self.THRESHOLD then
    trend = -1
  else
    trend = 0
  end
  local summer = month >= 4 and month <= 9
  local range = top - bottom
  local constant = range / 22

  if summer then
    if trend > 0 then
      hpa = hpa + (7 / 100 * range)
    elseif trend < 0 then
      hpa = hpa - (7 / 100 * range)
    end
  end

  if hpa == top then hpa = top - 1 end

  option = math.floor((hpa - bottom) / constant)
  if option >= 0 and option <= 22 then
    if trend > 0 then
      result = self.FORECAST[self.RISING[option + 1]]
    elseif trend < 0 then
      result = self.FORECAST[self.FALLING[option + 1]]
    else
      result = self.FORECAST[self.STEADY[option + 1]]
    end
  end

  return result
end

return zambretti
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
