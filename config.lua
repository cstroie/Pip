-- Main configuration

-- Device name
NODENAME = "NodeMCU"
TZ = 2

-- WiFi
wl_ap = {}
wl_ap["ssid"] = "pass"
wl_tries = 20

-- LCD
lcd_id  = 0
lcd_sda = 1      -- GPIO5
lcd_scl = 2      -- GPIO4
lcd_dev = 0x27   -- I2C Address
lcd_bl  = true   -- Backlight

-- PIR
pir_pin = 5
pir_interval = 300

-- NTP server
ntp_server = "0.europe.pool.ntp.org"
ntp_interval = "765"

-- DHT pin
dht11_pin = 4
dht11_interval = "60"

-- WX
wx_station = "ROXX0003"

-- IoT MQTT
iot_server = "mqtt.example.com"
iot_port = 1883
iot_id = "MQTT_ID"
iot_user = "MQTT_USER"
iot_pass = "MQTT_PASS"

-- Beep
beep_pin = 10
beep_pls = 500
beep_rpt = 100

-- RCS
rcs_pin = 3
rcs_pl = 320
rcs_bits = 24
rcs_proto = 1
rcs_count = 4
rcs_dip = 0x1f

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
