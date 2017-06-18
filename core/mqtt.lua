mqttServer = "localhost"
mqttPort = 80
mqttClient = deviceName
mqttTimeout = 120
mqttUser = "USER"
mqttPasswd = "PASSWORD"

-- Start up mqtt
mqttClient = mqtt.Client(mqttClient, mqttTimeout, mqttUser, mqttPasswd)
mqttClient:lwt("/lwt", "offline", 0, 0)
mqttClient:on("offline", function(con) print ("offline") end)

-- MQTT Message Processor
mqttClient:on("message", function(conn, topic, msg)
   _TOPIC = topic
   _MSG = msg
   node.task.post(appMessageProcessor);
end)  

-- Secure and autoreconnect
mqttClient:connect(mqttServer, mqttPort, 0, 1, function(conn)
                                          print("mqtt connected")
                                          --Don't remove topic from table
                                          --We need it in case of reconnect
                                          for k,v in pairs(pushTopics) do
                                             print("subscribing: "..v) 
                                             mqttClient:subscribe(v, 0, function(conn)
                                                print("subscribed") 
                                             end)
                                          end
                                          --Now client is connected. Consume Req
                                          node.task.post(reqConsumer);
                                       end,
                                       function(client, reason)
                                          print("failed reason: "..reason)
                                       end
)

function mqttClientPost(topic, msg)
   mqttClient:publish(topic.."/result", msg, 0, 0, function(client)
	print("sent");
	--Send next msg
	node.task.post(reqConsumer);
   end)
end
