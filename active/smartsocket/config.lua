--Feed details
systemName = "dofthings"
feedID = 8
feedHash = "adafac59844370ce2b9a6ae8a296b468d49605f904e207ae1b82d6847ebf21a7"
feed = "/"..feedID.."/"..feedHash
deviceName = wifi.sta.getmac()
deviceType = "active"
deviceInitiated = 0

ioft_action_usr = "USER"
ioft_action_pwd = "PASSOWRD"

--Sensors/Methods
supportedActions = { smartSocketOne = 1 }
supportedSensors = nil
supportedSensorTriggers = nil

--Sleep time
sleep_en = 0
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

--gpios
buttonPin = 3
relayPin = 6
ledPin = 7

--Queues
pushReqs = {}
pushTopics = {}

--Global topic msg variables
_MQTT_EN = 1
_TOPIC = nil
_MSG = nil
