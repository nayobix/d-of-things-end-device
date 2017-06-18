--Led functions On/Off
mpin = 0

function setMpin(ledPin)
    mpin = ledPin
end

function ledBlinkSpecify(ledPin)
        setMpin(ledPin)
        ledBlink()
end
 
function ledBlink()
        gpio.mode(mpin, gpio.OUTPUT)
        gpio.write(mpin, gpio.LOW)
        tmr.delay(500000)   -- wait 500,000 us = 0.5 second
        gpio.write(mpin, gpio.HIGH)
end

function ledOn()
        gpio.mode(mpin, gpio.OUTPUT)
        gpio.write(mpin, gpio.LOW)
end

function ledOff()
        gpio.mode(mpin, gpio.OUTPUT)
        gpio.write(mpin, gpio.HIGH)
end

function led(v)
    val = tonumber(v)
    if (val > 0) then
        ledOn()
    else
        ledOff()
    end

    return val
end

--Queue functions
--Enqueue request
function reqProducer(topic, json)
    local req = {}
    req[topic] = json
    collectgarbage();
    table.insert(pushReqs, req);
    collectgarbage();
end

--Dequeue request
function reqConsumer()
    local Req = nil
    collectgarbage()
    if (#pushReqs > 0) then
        local r = table.remove(pushReqs)
        for t, m in pairs(r) do
            print("\nt: "..t);
            print("\nm: "..m);
            if (_MQTT_EN == 0) then
                Req = require("post")
                Req.clientPost(m)
            elseif (_MQTT_EN == 1) then
                mqttClientPost(t, m)
            else
                print("Unsupported request type");
            end
        end
        return;
    end
    collectgarbage()
    --No more requests so execute the final steps
    node.task.post(appFinalSteps);
end

--Push topic for subscription
function getTopicName()
    topic = "/"..systemName..""..feed.."/"..deviceName.."/"..deviceType

    return topic
end

--Push topic for subscription
function pushTopic(topic)
    for k,v in pairs(pushTopics) do
        if v == topic then return end
    end
    --Insert only if value is not already there
    table.insert(pushTopics, topic)
end

function globalFinalSteps()                                                           

    --Final steps
    deviceInitiated = 1
    if (sleep_en == 1) then
        print('Going to sleep for [us]: '..sleep_time_us)
        node.dsleep(sleep_time_us) --Deep sleep defined in config.lua
    end
end

--
--Pinmux setup
--0 - don't configure
--1 - input
--2 - output/high
--3 - output/low
function initBoard()
	--Set all gpios to the proper state low/high and so on
	for k,v in ipairs(gpioPinmux) do
		if (gpioPinmux[k] == 1) then
			gpio.mode(k, gpio.INPUT)
		elseif (gpioPinmux[k] == 2) then
			gpio.mode(k, gpio.OUTPUT)
			gpio.write(k, gpio.HIGH)
		elseif (gpioPinmux[k] == 3) then
			gpio.mode(k, gpio.OUTPUT)
			gpio.write(k, gpio.LOW)
		else
			print('Unsupported pinmux option...\n')
		end
	end

end
