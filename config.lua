-- Main configuration
CFG = {}

-- Global device data
NODENAME = "NodeMCU"  -- device name
TZ = 0                -- timezone

-- WiFi
CFG.WL = {}
CFG.WL.tries = 20
CFG.WL.AP = {}
CFG.WL.AP["ssid"] = "pass"

-- NTP server
CFG.NTP = {}
CFG.NTP.server = "0.europe.pool.ntp.org"
CFG.NTP.interval = 765

-- Thermistor
CFG.TH = {}
CFG.TH.interval = 60

-- IoT MQTT
CFG.IOT = {}
CFG.IOT.server = "mqtt.example.com"
CFG.IOT.port = 1883
CFG.IOT.ssl = 0
CFG.IOT.auto = 1
CFG.IOT.id = "MQTT_ID"
CFG.IOT.user = "MQTT_USER"
CFG.IOT.pass = "MQTT_PASS"

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
