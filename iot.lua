-- MQTT integration for IoT

require("config")
wx = require("wx")

local iot = {}
iot.connected = false

function iot:sub()
  --self.client:subscribe({["wx/#"] = 1, ["sensor/outdoor/#"] = 1, ["command/#"] = 1})
  self.client:subscribe("wx/" .. wx_station .. "/#", 1)
  self.client:subscribe("command/" .. NODENAME:lower() .. "/#", 1)
  self.client:subscribe("command/rcs/#", 1)
  local ssid = wifi.sta.getconfig()
  local ip, nm, gw = wifi.sta.getip()
  local topmsg = {hostname = wifi.sta.gethostname(),
                  mac = wifi.sta.getmac(),
                  ssid = ssid,
                  rssi = wifi.sta.getrssi(),
                  ip = ip,
                  gw = gw}
  self:mpub({wifi = topmsg}, 1, 1, "report/" .. NODENAME:lower())
  local sec, usec = rtctime.get()
  if sec ~= 0 then
    local tm = rtctime.epoch2cal(sec + TZ * 3600)
    local ts = string.format("%04d.%02d.%02d %02d:%02d:%02d",
                              tm["year"], tm["mon"], tm["day"],
                              tm["hour"], tm["min"], tm["sec"])
    self:pub("report/" .. NODENAME:lower() .. "/time", ts, 1, 1)
  end
end

function iot:init()
  self.client = mqtt.Client(iot_id, 120, iot_user, iot_pass, 1)
  self.client:lwt("lwt", NODENAME .. " is offline", 0, 0)
  self.client:on("connect", function(client)
    debug("IoT connected")
    self.connected = true
    self:sub()
  end)
  self.client:on("offline", function(client)
    debug("IoT offline")
    self.connected = false
  end)
  self.client:on("message", function(client, topic, msg)
    if msg then
      debug("IoT " .. topic .. ": " .. msg)
      local root, trunk, branch = string.match(topic, '^([^/]+)/([^/]+)/([^/]+)')
      if root == "wx" and trunk == wx_station then
        wx:weather(branch, msg)
      elseif root == "sensor" and trunk == "outdoor" then
        if branch == "temperature" then
          OUT_T = string.match(msg, '^([^.]+)')
        elseif branch == "humidity" then
          OUT_H = string.match(msg, '^([^.]+)')
        elseif branch == "sealevel" then
          OUT_P = string.match(msg, '^([^.]+)')
        elseif branch == "dewpoint" then
          OUT_D = string.match(msg, '^([^.]+)')
        end
      elseif root == "command" then
        if trunk == "rcs" then
          local rcs = require("rcs").button(branch, msg)
        elseif trunk:lower() == NODENAME:lower() then
          if branch == "restart" then
            node.restart()
          elseif branch == "debug" then
            DEBUG = (msg == "on") and true or false
          elseif branch == "timezone" then
            TZ = tonumber(msg)
          elseif branch == "ntpsync" then
            local server = msg and msg or ntp_server
            sntp.sync(server)
          elseif branch == "beep" then
            local beep = require("beep").onekhz()
          elseif branch == "light" then
            lcd_bl = (msg == "on") and true or false
          end
        end
      end
    end
  end)
end

function iot:connect()
  if wifi.sta.status() == wifi.STA_GOTIP then
    self.client:close()
    self.client:connect(iot_server, iot_port, 0, 1,
    function(client)
      debug("IoT initial connection")
      self.connected = true
      self:sub()
    end)
  else
    self.connected = false
  end
end

function iot:pub(topic, msg, qos, ret)
  -- Publish the message to a topic
  if not self.connected then
    self:connect()
  elseif wifi.sta.status() == wifi.STA_GOTIP then
    qos = qos and qos or 0
    ret = ret and ret or 0
    msg = msg or ""
    debug("IoT publish: " .. topic .. ": ", msg)
    self.client:publish(topic, msg, qos, ret)
  else
    self.connected = false
  end
end

function iot:mpub(topmsg, qos, ret, btop)
  -- Publish the messages to their topics
  if not self.connected then
    self:connect()
  elseif wifi.sta.status() == wifi.STA_GOTIP then
    qos = qos and qos or 0
    ret = ret and ret or 0
    btop = btop:sub(#btop,#btop) ~= "/" and btop .. "/" or btop
    for topic, msg in pairs(topmsg) do
      if type(msg) == "table" then
        self:mpub(msg, qos, ret, btop .. topic)
      else
        msg = msg or ""
        debug("IoT publish: " .. btop .. topic .. ": ", msg)
        self.client:publish(btop .. topic, msg, qos, ret)
      end
    end
  else
    self.connected = false
  end
end

return iot
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
