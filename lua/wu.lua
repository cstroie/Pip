module(..., package.seeall);

local http = require("socket.http")
local url = require("socket.url")

local wu = {data = {}}

function wu:collect(key, value)
  if value ~= nil then
    self.data[key] = value
  end
end

function wu:clear()
  self.data = {}
end

function wu:post(id, pass)
  local body = "action=updateraw&dateutc=now&ID=" .. id .. "&PASSWORD=" .. pass .. "&softwaretype=WxSta"
  for k,v in pairs(self.data) do
    body = body .. "&" .. k .. "=" .. url.escape(v)
  end
  return http.request("https://weatherstation.wunderground.com/weatherstation/updateweatherstation.php", body)
end

return wu
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
