--Feed details
feedID = 5
feedHash = "30affa18813d27af843901e699f777a824b67aab91a119b508950c027e7f033e"
feed = "/"..feedID.."/"..feedHash
deviceName = wifi.sta.getmac()

--Sensors/Methods
methodActionNameUri = "executeAction"
--supportedMethods = { "doorIntercom" = 1 }
supportedMethods = nil
--1 - temperature, 2 - door status, 3 - humidity
supportedSensors = { temp = 1, humidity = 3 } 
--supportedSensors = { humidity = 3 } 
--supportedSensorTriggers = { doorOut = 4 } --gpio number
supportedSensorTriggers = nil

--Sleep time
sleep_en = 1
--sleep infinite
sleep_time_us = 0

--gpio pinmux 
--0 - dont configure (usualy used for temp sensor, since it configures on its own
--1 - input
--2 - output/high
--3 - output/low
--TODO: update pinmux
gpioPinmux = {}
gpioPinmux[3] = 0;
gpioPinmux[4] = 1;

-- Push requests queue
pushReqs = {}
