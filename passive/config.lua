--Feed details
systemName = "dofthings"
feedID = 5
feedHash = "30affa18813d27af843901e699f777a824b67aab91a119b508950c027e7f033e"
feed = "/"..feedID.."/"..feedHash
deviceName = wifi.sta.getmac()
deviceType = "passive"
deviceInitiated = 0

ioft_action_usr = "USER"
ioft_action_pwd = "PASSWORD"

--Sensors/Methods
supportedMethods = nil
supportedSensors = { temp = 1, humidity = 3 } 
supportedSensorTriggers = nil

--Sleep time
sleep_en = 1
sleep_time_us = 300000000

--gpio pinmux 
--0 - dont configure (usualy used for temp sensor, since it configures on its own
--1 - input
--2 - output/high
--3 - output/low
--TODO: update pinmux
gpioPinmux = {}
gpioPinmux[3] = 0;
gpioPinmux[4] = 1;

--Queues
pushReqs = {}
pushTopics = {}

--Global topic msg variables
_MQTT_EN = 1
_TOPIC = nil
_MSG = nil
