module(..., package.seeall);

local http = require("socket.http")
local url = require("socket.url")

local thingspeak = {data = {}}

function thingspeak:collect(key, value)
  if value ~= nil then
    self.data[key] = value
  end
end

function thingspeak:clear()
  self.data = {}
end

function thingspeak:post(api_key)
  local body = "api_key=" .. api_key
  for k,v in pairs(self.data) do
    body = body .. "&" .. k .. "=" .. url.escape(v)
  end
  return http.request("https://api.thingspeak.com/update", body)
end

return thingspeak
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
