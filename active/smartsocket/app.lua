--
--Make json with the proper name and value
--
function getJson(name, value)

    topic = getTopicName()
    actionUri = topic.."/"..name

    if (topic == nil or value < 0) then return nil; end

    json='{"FeedID":"'..feedID..'", "FeedKeyHash":"'..feedHash..'", "deviceName":"'..deviceName..'", "deviceID":1, "objectType": "Method", "objectName": "'..name..'", "objectAction":"'..actionUri..'", "objectValue": '..value..', "timestamp": "TSNONE"}'

    return json
end

--
--Method action
--Action: 
--where:
--0 - Down
--1 - Up
--2 - Flip flop
function methodActionUpDown(gpio_pin, where)
	--gpio2 = 4
	if (where == 0) then
		gpio.mode(gpio_pin, gpio.OUTPUT)
		gpio.write(gpio_pin, gpio.LOW)
	elseif (where == 1) then
		gpio.mode(gpio_pin, gpio.OUTPUT)
		gpio.write(gpio_pin, gpio.HIGH)
	elseif (where == 2) then
		gpio.mode(gpio_pin, gpio.OUTPUT)
		gpio.write(gpio_pin, gpio.LOW)
		tmr.delay(delay_s * 1000000)   -- wait delay_s
		gpio.write(gpio_pin, gpio.HIGH)
	end
end

--
--Update smartSocket status
--
function updateSmartSocketOneStatus(p, topic, action)
   state = gpio.read(p)
   --Invert the state and update it
   if (state == 0) then
      state = 1
   else
      state = 0
   end
   print('Update button status: '..state)
   _smartSocketOne(topic, action, state)
end

function _smartSocketOne(topic, action, val)
   val = 0
   if (val > 0) then
      val = 1
   end
   methodActionUpDown(relayPin, val)
   json = getJson(action, val)
   if (json ~= nil) then
      reqProducer(topic, json);
   end
end

function smartSocketButtonIrq(p, t, a)
   print('Registering button irq\n')
   gpio.mode(p, gpio.INT)
   gpio.trig(p, "down",
      function(level, pulse2)
	 print('Button clicked topic: '..t..' msg: '..a)
         updateSmartSocketOneStatus(relayPin, t, a)
	 gpio.trig(p, "down")
      end)

end

--
--Update actions
function updateActions()
    if (supportedActions == nil) then return; end
    for k,v in pairs(supportedActions) do
	local json
	topic = getTopicName()
	t_result = topic
	if (supportedActions[k] == 1) then
	    --Init relay pin to OFF always, when it is restarted
	    methodActionUpDown(relayPin, 0)
	    json = getJson(k, 0)
	    if (json ~= nil) then reqProducer(t_result, json) end
	    --Init irq trigger for button
	    smartSocketButtonIrq(buttonPin, topic, k)
	else
	    print('Unsupported method update...\n')
	end
	pushTopic(topic);
    end
end

function appFinalSteps()

    if (deviceInitiated == 0) then
	--Put here steps which should exec only after boot
    end
    print('Executing final steps\n')
    node.task.post(globalFinalSteps);
end

function appMessageProcessor()
    print('Message processing: topic: '.._TOPIC..' msg: '.._MSG)
    msgAction, msgValue = _MSG:match("([^,]+):([^,]+)")
    functions[msgAction](_TOPIC, msgAction, msgValue)
    reqConsumer(); --Consume new requests
end

functions = {
       smartSocketOne = function(topic, action, value) _smartSocketOne(topic, action, value) end,
}

--
--Main
--
function main()
    counter = 0
    collectgarbage();
    print('\nRunning app.lua\n');
    --Try to update data 3 times, 
    tmr.alarm(2, 10000, 1, function()
	if (wifi.sta.getip() ~= nil) then
	    tmr.stop(2);
	    updateActions();
	    --Action are enqueued. Now start mqtt client. Continue after it 
	    --is connected. Will continue with appFinalSteps
	    dofile("mqtt.lua");
	elseif (wifi.sta.getip() == nil and counter > 2) then
	    print('Skip posting. Restarting...\n');
	    tmr.stop(2);
	    node.restart();
	else
	    counter = counter + 1
	    ledBlinkSpecify(ledPin);
	    print('Skip posting. Reconnecting...\n');
	end
    end);
end

main()
