module(..., package.seeall);

local CALLSIGN = "FW0690"
local PASSCODE = "-1"
local LOCATION = "4427.43N/02607.59E"

local APRS_SERVER = "cwop.aprs.net"
local APRS_PORT = 14580


local socket = require("socket")

local aprs = {data = {}, tmcnt = 0}

-- Random seq
math.randomseed(os.time())
aprs.stseq = math.random(999)

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
    text = "user " .. CALLSIGN .. " pass " .. PASSCODE .. " vers WxIno 0.1"
    con:send(text .. "\r\n")
    line = con:receive("*l")
    --print(line)
    text = CALLSIGN .. ">APRS,TCPIP*:" ..
           "@" .. os.date("!%d%H%M") .. "z" ..
           LOCATION ..
           "_.../...g..." ..
           "t" .. string.format("%03d", math.floor(tfar)) ..
           "h" .. string.format("%02d",  math.floor(self.data["hmdt"])) ..
           "b" .. string.format("%05d",  math.floor(self.data["pres"] * 10)) ..
           "L" .. string.format("%03d",  math.floor(self.data["lux"] * 0.0079)) ..
           "WxIno"
    con:send(text .. "\r\n")
    print(text)

    -- Telemetry http://www.aprs.net/vm/DOS/TELEMTRY.HTM
    -- "PARM.Battery,Charging/AC,GPS+Sat,A4,A5,A/C,Charging,GPS,B4,B5,B6,B7,B8", /* Channel names */
    -- "UNIT.Percent,Charge/On/Off,Sats/On/Off,N/A,N/A,On,Yes,On,N/A,N/A,N/A,N/A,N/A",/* Units */
    -- "EQNS.0,1,0,0,1,0,0,1,0,0,1,0,0,1,0", /* (a*v^2 + b*v + c) 5 times! */
    -- "BITS.11111111,Battery State Tracking" /* Bit sense and project name */
    -- T#sss,111,222,333,444,555,xxxxxxxx  /* where sss is the serial number */
    --
    -- T#829,100,048,002,500,000,10000000

    -- Send the config first
    if self.tmcnt <= 1 then
      text = CALLSIGN .. ">APRS,TCPIP*::" .. CALLSIGN .. "   :PARM.Vcc,RSSI,Heap,IRed,Vis,B1,B2,B3,B4,B5,B6,B7,B8"
      con:send(text .. "\r\n")
      print(text)
      text = CALLSIGN .. ">APRS,TCPIP*::" .. CALLSIGN .. "   :EQNS.0,0.004,2.5,0,-1,0,0,200,0,0,255,0,0,255,0"
      con:send(text .. "\r\n")
      print(text)
      text = CALLSIGN .. ">APRS,TCPIP*::" .. CALLSIGN .. "   :UNIT.V,dBm,Bytes,units,units,N/A,N/A,N/A,N/A,N/A,N/A,N/A,N/A"
      con:send(text .. "\r\n")
      print(text)
      text = CALLSIGN .. ">APRS,TCPIP*::" .. CALLSIGN .. "   :BITS.11111111,WxStation"
      con:send(text .. "\r\n")
      print(text)
    end

    -- Send the telemetry
    if self.tmcnt == 0 then
      self.tmcnt = self.stseq
    end
    text = CALLSIGN .. ">APRS,TCPIP*:T#" ..
           string.format("%03d", self.tmcnt) .. "," ..
           string.format("%03d", math.floor((self.data["vcc"] - 2.5) * 250)) .. "," ..
           string.format("%03d", -self.data["rssi"]) .. "," ..
           string.format("%03d", math.floor(self.data["heap"] / 200)) .. "," ..
           string.format("%03d", math.floor(self.data["visb"] / 255)) .. "," ..
           string.format("%03d", math.floor(self.data["ired"] / 255)) .. "," ..
           "00000000"
    con:send(text .. "\r\n")
    print(text)

    -- Increment the counter and reset it after 8 hours
    -- TODO use a timer
    self.tmcnt = self.tmcnt + 1
    if self.tmcnt >= 999 then
      self.tmcnt = 1
    end
    if self.tmcnt > self.stseq then
      if self.tmcnt - self.stseq > 480 then
        self.tmcnt = 1
      end
    elseif 999 + self.tmcnt - self.stseq > 480 then
      self.tmcnt = 1
    end

    -- Close the connection
    con:close()
  end
end

return aprs
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
