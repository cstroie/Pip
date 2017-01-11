module(..., package.seeall);

local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")

local ubidots = {data = {}}

function ubidots:collect(variable, value)
  self.data[variable] = tonumber(value)
end

function ubidots:clear()
  self.data = {}
end

function ubidots:post(datasource, token)
  payload = cjson.encode(self.data)
  local response_body = {}
  response, http_code, http_headers = http.request
  {
    url = "http://things.ubidots.com/api/v1.6/devices/" .. datasource .. "/",
    method = "POST",
    headers = {["Content-Type"] = "application/json",
               ["Content-Length"] = #payload,
               ["X-Auth-Token"] = token},
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }
end

return ubidots
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
