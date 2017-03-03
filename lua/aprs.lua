module(..., package.seeall);

local CALLSIGN = "RO3DNG"
local PASSCODE = "23726"
local LOCATION = "4427.43N/02607.59E"

local APRS_SERVER = "cbaprs.de"
local APRS_PORT = 27235


local socket = require("socket")

local aprs = {data = {}}

function aprs:collect(key, value)
  self.data[key] = value
end

function aprs:clear()
  self.data = {}
end

function aprs:post()
  local text, line
  local tfar = self.data["temp"] * 9 / 5 + 32
  local con = socket.connect(APRS_SERVER, APRS_PORT)
  if (con ~= nil) then
    line = con:receive("*l")
    --print(line)
    text = "user " .. CALLSIGN .. " pass " .. PASSCODE .. " vers wxcbaprs 0.1"
    con:send(text .. "\r\n")
    line = con:receive("*l")
    --print(line)
    text = CALLSIGN .. "-10" ..
           ">APRS,TCPIP*:" ..
           "/" .. os.date("!%d%H%M") .. "z" ..
           LOCATION ..
           "_.../...g..." ..
           "t" .. string.format("%03d", math.floor(tfar)) ..
           "h" .. string.format("%02d",  math.floor(self.data["hmdt"])) ..
           "b" .. string.format("%05d",  math.floor(self.data["pres"] * 10)) ..
           "xLWX"
    con:send(text .. "\r\n")
    print(text)
    con:close()
  end
end

return aprs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
