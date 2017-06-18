--
--Make sensor json with the proper value
--what:
--1 - Sensor json
--2 - Method json
--
function getJson(what, sensorName, sensorValue)

	if (what == 1) then
		if (sensorName == nil or sensorValue == nil) then return nil; end

		json='{"FeedID":"'..feedID..'", "FeedKeyHash":"'..feedHash..'", "deviceName":"'..deviceName..'", "deviceID":1, "objectType": "Sensor", "objectName": "'..sensorName..'", "objectAction": "NONE", "objectValue": '..sensorValue..', "timestamp": "TSNONE"}'
	elseif (what == 2) then
		if (wifi.sta.getip() ~= nil) then
			methodUri = "http://"..wifi.sta.getip().."/"..methodActionNameUri
		else
			methodUri = nil
		end
		if (methodUri == nil or actionValue == nil) then return nil; end

		actionUri = methodUri.."/"..actionName
		json='{"FeedID":"'..feedID..'", "FeedKeyHash":"'..feedHash..'", "deviceName":"'..deviceName..'", "deviceID":1, "objectType": "Method", "objectName": "'..actionName..'", "objectAction":"'..actionUri..'", "objectValue": '..actionValue..', "timestamp": "TSNONE"}'
	end

    return json
end

--
--Read temperature sensor value
--
function getSensorTemp()
    pin = 5
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
	tmr.delay(1000000)   -- wait 1.000,000 us = 1 second
	return temp
    elseif status == dht.ERROR_CHECKSUM then
	print( "DHT Checksum error." )
	return nil
    elseif status == dht.ERROR_TIMEOUT then
	print( "DHT timed out." )
	return nil
    end
end

--
--Read humidity sensor value
--
function getSensorHumi()
    pin = 5
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
	tmr.delay(1000000)   -- wait 1.000,000 us = 1 second
	return humi
    elseif status == dht.ERROR_CHECKSUM then
	print( "DHT Checksum error." )
	return nil
    elseif status == dht.ERROR_TIMEOUT then
	print( "DHT timed out." )
	return nil
    end
end
 
--
--Method action
--Action: 
--where:
--0 - Down
--1 - Up
--2 - Flip flop
function methodActionUpDown(where)
	--gpio2 = 4
	if (where == 0) then
		gpio.mode(4, gpio.OUTPUT)
		gpio.write(4, gpio.LOW)
	elseif (where == 1) then
		gpio.mode(4, gpio.OUTPUT)
		gpio.write(4, gpio.HIGH)
	elseif (where == 2) then
		gpio.mode(4, gpio.OUTPUT)
		gpio.write(4, gpio.LOW)
		tmr.delay(delay_s * 1000000)   -- wait delay_s
		gpio.write(4, gpio.HIGH)
	end
end

--
--
--
--Update door status
--
function updateDoorStatus(name, mgpio, level)
	--state = gpio.read(3)
	--publish it's state
	json = getJson(1, name, level)
	if (json ~= nil) then 
		reqProducer(json); 
	end
end

--
--Update sensors
--what:
--1 - Sensors
--2 -- Methods
--3 - Trigger sensors
function updateSensorsMethods(what)

	if (what == 1) then
		if (supportedSensors == nil) then return; end
		for k,v in pairs(supportedSensors) do
			if (supportedSensors[k] == 1) then
				json = getJson(1, k, getSensorTemp())
				if (json ~= nil) then reqProducer(json); end
			elseif (supportedSensors[k] == 2) then
				--json = getJson(1, k, getDoorStatus())
				json = getJson(1, k, gpio.read(3))
				if (json ~= nil) then reqProducer(json); end
			elseif (supportedSensors[k] == 3) then
				json = getJson(1, k, getSensorHumi())
				if (json ~= nil) then reqProducer(json); end
			else
				print('Unsupported sensor update...\n')
			end
		end
	elseif (what == 2) then
		if (supportedMethods == nil) then return; end
		for k,v in ipairs(supportedMethods) do
			if (supportedMethods[k] == 1) then
				json = getJson(2, k, getDoorStatus());
				if (json ~= nil) then reqProducer(json); end
			else
				print('Unsupported method update...\n')
			end
		end
	elseif (what == 3) then
		if (supportedSensorTriggers == nil) then return; end
		for k,mgpio in ipairs(supportedSensorTriggers) do
			gpio.trig(mgpio, "both", function(level) updateDoorStatus(k, mgpio, level); end)
		end

		--gpio.trig(mgpio, "both", function (level)
		--	state = gpio.read(3)
		--	print("Sent openhab/garage/switch1 " .. state )
		--	end)
	end
end

--
--Pinmux setup
--0 - don't configure
--1 - input
--2 - output/high
--3 - output/low
--function initBoard()
--	--Set all gpios to the proper state low/high and so on
--	for k,v in ipairs(gpioPinmux) do
--		if (gpioPinmux[k] == 1) then
--			gpio.mode(k, gpio.INPUT)
--		elseif (gpioPinmux[k] == 2) then
--			gpio.mode(k, gpio.OUTPUT)
--			gpio.write(k, gpio.HIGH)
--		elseif (gpioPinmux[k] == 3) then
--			gpio.mode(k, gpio.OUTPUT)
--			gpio.write(k, gpio.LOW)
--		else
--			print('Unsupported pinmux option...\n')
--		end
--	end
--
--end

--
--Main
--
function main()
    counter = 0
    collectgarbage();
    print('\nRunning app.lua\n');
    --initBoard();
    --updateSensorsMethods(2); -- Update methods when boot the board
    --Try to update data 3 times, 
    tmr.alarm(2, 10000, 1, function()
	if (wifi.sta.getip() ~= nil) then
	    tmr.stop(2)
	    updateSensorsMethods(1); --Update sensors and enqueue requests
	    reqConsumer(); --Consume requests
	elseif (wifi.sta.getip() == nil and counter > 2) then
	    print('Skip posting. Restarting...\n');
	    tmr.stop(2)
	    node.restart()
	else
	    counter = counter + 1
	    ledBlink();
	    print('Skip posting. Reconnecting...\n');
	end
    end);
end

main()
