-- MQTT integration for IoT

require("config")
wx = require("wx")

local iot = {}
iot.connected = false

function iot:init()
  self.client = mqtt.Client(iot_id, 120, iot_user, iot_pass, 1)
  self.client:lwt("lwt", NODENAME .. "offline", 0, 0)
  self.client:on("connect", function(client)
    debug("IoT connected")
    self.connected = true
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
      elseif root == "command" then
        if trunk == "rcs" then
          local rcs = require("rcs")
          rcs:button(branch, msg)
          unrequire("rcs")
        elseif trunk == NODENAME then
          if branch == "restart" then
            node.restart()
          elseif branch == "debug" then
            DEBUG = (msg == "on") and true or false
          elseif branch == "timezone" then
            timezone = msg
          elseif branch == "ntpsync" then
            local server = msg and msg or ntp_server
            sntp.sync(server)
          elseif branch == "beep" then
            local beep = require("beep")
            beep:onekhz()
            unrequire("beep")
          elseif branch == "light" then
            lcd_bl = (msg == "on") and true or false
          end
        end
      end
    end
  end)
end

function iot:connect()
  if wifi.sta.status() == 5 then
    self.client:close()
    self.client:connect(iot_server, iot_port, 0, 1,
    function(client)
      debug("IoT initial connection")
      self.connected = true
      self.client:subscribe({["wx/#"] = 1, ["command/#"] = 1})
      local ssid = wifi.sta.getconfig()
      local ip, nm, gw = wifi.sta.getip()
      local root = "report/" .. NODENAME .. "/wifi/"
      self:pub(root .. "hostname", wifi.sta.gethostname(), 1, 1)
      self:pub(root .. "mac", wifi.sta.getmac(), 1, 1)
      self:pub(root .. "ssid", ssid, 1, 1)
      self:pub(root .. "rssi", wifi.sta.getrssi(), 1, 1)
      self:pub(root .. "ip", ip, 1, 1)
      self:pub(root .. "gw", gw, 1, 1)
    end,
    function(client, reason)
      debug("IoT failed: " .. reason)
      self.connected = false
    end)
  end
end

function iot:pub(topic, msg, qos, ret)
  -- Publish the message to a topic
  if wifi.sta.status() == 5 and self.connected and msg ~= nil then
    qos = qos and qos or 0
    ret = ret and ret or 0
    debug("IoT publish: " .. topic .. ": ", msg)
    self.client:publish(topic, msg, qos, ret)
  end
end

return iot
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
