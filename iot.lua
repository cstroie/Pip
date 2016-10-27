-- IoT

require("config")
rcs = require("rcs")
wx = require("wx")

local iot = {}
iot.connected = false

function iot:init()
  self.client = mqtt.Client(iot_id, 120, iot_user, iot_pass, 1)
  self.client:on("connect", function(client)
    if DEBUG then print("IoT connected") end
    self.connected = true
    local ssid = wifi.sta.getconfig()
    local ip, nm, gw = wifi.sta.getip()
    self:pub("node/wifi/ssid", ssid, 1, 1)
    self:pub("node/wifi/ip", ip, 1, 1)
    self:pub("node/wifi/gw", gw, 1, 1)
    self:pub("node/wifi/hostname", wifi.sta.gethostname(), 1, 1)
    self:pub("node/wifi/mac", wifi.sta.getmac(), 1, 1)
  end)
  self.client:on("offline", function(client)
    if DEBUG then print("IoT offline") end
    self.connected = false
  end)
  self.client:on("message", function(client, topic, msg)
    if msg then
      if DEBUG then print("IoT " .. topic .. ": " .. msg) end
      local root, sect, id = string.match(topic, '^([^/]+)/([^/]+)/([^/]+)')
      if root == "wx" and sect == wx_station then
        wx:weather(id, msg)
      elseif root == "eridu" and sect == "rcs" then
        rcs:button(id, msg)
      elseif topic == "node/command" then
        if msg == "restart" then node.restart() end
      elseif topic == "node/command/debug" then
        DEBUG = (msg == "on") and true or false
      elseif topic == "node/command/timezone" then
        timezone = msg
      elseif topic == "node/command/ntpsync" then
        local server = msg and msg or ntp_server
        sntp.sync(server)
      end
    end
  end)
end

function iot:connect()
  if wifi.sta.status() == 5 then
    self.client:close()
    self.client:connect(iot_server, iot_port, 0, 1,
    function(client)
      if DEBUG then print("IoT initial connection") end
      self.connected = true
      self.client:subscribe({["eridu/#"] = 1, ["wx/#"] = 1, ["node/#"] = 1})
    end,
    function(client, reason)
      if DEBUG then print("IoT failed: " .. reason) end
      self.connected = false
    end)
  end
end

function iot:pub(topic, msg, qos, ret)
  if qos == nil then qos = 0 end
  if ret == nil then ret = 0 end
  if self.connected then
    if DEBUG then print("IoT publish: " .. topic .. ": ", msg) end
    self.client:publish(topic, msg, qos, ret)
  end
end

return iot
-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
