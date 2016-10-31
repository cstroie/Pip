-- IoT

require("config")
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
    self:pub("node/wifi/hostname", wifi.sta.gethostname(), 1, 1)
    self:pub("node/wifi/mac", wifi.sta.getmac(), 1, 1)
    self:pub("node/wifi/ssid", ssid, 1, 1)
    self:pub("node/wifi/rssi", wifi.sta.getrssi(), 1, 1)
    self:pub("node/wifi/ip", ip, 1, 1)
    self:pub("node/wifi/gw", gw, 1, 1)
  end)
  self.client:on("offline", function(client)
    if DEBUG then print("IoT offline") end
    self.connected = false
  end)
  self.client:on("message", function(client, topic, msg)
    if msg then
      if DEBUG then print("IoT " .. topic .. ": " .. msg) end
      local root, trunk, branch, leaf = string.match(topic, '^([^/]+)/([^/]+)/([^/]+)')
      if root == "wx" and trunk == wx_station then
        wx:weather(branch, msg)
      elseif root == "eridu" and trunk == "rcs" then
        local rcs = require("rcs")
        rcs:button(branch, msg)
        unrequire("rcs")
      elseif root == "node" and trunk == node.chipid() then
        if branch == "command" then
          if leaf == "restart" then
            node.restart()
          elseif leaf == "debug" then
            DEBUG = (msg == "on") and true or false
          elseif leaf == "timezone" then
            timezone = msg
          elseif leaf == "ntpsync" then
            local server = msg and msg or ntp_server
            sntp.sync(server)
          elseif leaf == "beep" then
            local beep = require("beep")
            beep:onekhz()
            unrequire("beep")
          elseif leaf == "light" then
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
