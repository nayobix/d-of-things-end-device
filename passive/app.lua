--
--Make json with the proper name and value
--
function getJson(name, value)
    
    if (name == nil or value == nil) then return nil; end
    
    json='{"FeedID":"'..feedID..'", "FeedKeyHash":"'..feedHash..'", "deviceName":"'..deviceName..'", "deviceID":1, "objectType": "Sensor", "objectName": "'..name..'", "objectAction": "NONE", "objectValue": '..value..', "timestamp": "TSNONE"}'

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
--Update sensors
--what:
--1 - Sensors
--2 -- Methods
--3 - Trigger sensors
function updateSensorsMethods(what)
    if (supportedSensors == nil) then return; end
    for k,v in pairs(supportedSensors) do
	local json;
	topic = getTopicName()
	t_result = topic
	if (supportedSensors[k] == 1) then
	    json = getJson(k, getSensorTemp())
	    if (json ~= nil) then reqProducer(t_result, json); end
	elseif (supportedSensors[k] == 2) then
	    --json = getJson(k, getDoorStatus())
	    json = getJson(k, gpio.read(3))
	    if (json ~= nil) then reqProducer(t_result, json); end
	elseif (supportedSensors[k] == 3) then
	    json = getJson(k, getSensorHumi())
	    if (json ~= nil) then reqProducer(t_result, json); end
	else
	    print('Unsupported sensor update...\n')
	end
    end
end

function appFinalSteps()

    if (deviceInitiated == 0) then
	--Put here steps which should exec only after boot
    end
    print('Executing final steps\n')
    node.task.post(globalFinalSteps);
end

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
            --Sensors are enqueued. Now start mqtt client. Continue after it
            --is connected. Will continue with appFinalSteps
            dofile("mqtt.lua");
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
