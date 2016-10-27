-- Main configuration

-- WiFi
wl_ap = {}
wl_ap["ssid"] = "pass"
wl_tries = 20

-- LCD
lcd_id  = 0
lcd_sda = 1      -- GPIO5
lcd_scl = 2      -- GPIO4
lcd_dev = 0x27   -- I2C Address

-- NTP server
ntp_server = "0.europe.pool.ntp.org"
ntp_interval = "765"
timezone = 3

-- DHT pin
dht11_pin = 4
dht11_interval = "60"

-- WX
wx_station = "ROXX0003"

-- IoT MQTT
iot_server = "m21.cloudmqtt.com"
iot_port = 17223
iot_id = "MQTT_ID"
iot_user = "MQTT_USER"
iot_pass = "MQTT_PASS"

-- vim: set ft=lua ai ts=2 sts=2 et sw=2 sta nowrap nu :
