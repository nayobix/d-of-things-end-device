dofile("wificonfig.lua")
dofile("config.lua")
dofile("functions.lua")

function connectWifi()
    counter = 0
    counter_max = 5
    wifi.setmode(wifi.STATION)
    print('set mode=STATION (mode='..wifi.getmode()..')\n')
    print('MAC Address: ',wifi.sta.getmac())
    print('Chip ID: ',node.chipid())
    print('Heap Size: ',node.heap(),'\n')
    -- wifi config start
    wifi.sta.config(ssid,pass)
    -- wifi config end
    -- start trying to connect for 10s, if can't then go to wifi setup mode
    tmr.alarm(0, 2000, 1, function()
        if (wifi.sta.getip() == nil) and (counter < counter_max) then
            print("Connecting to AP: "..ssid.." Try: "..counter)
            print("app.lua will not start until device is connected...\n")
        elseif (wifi.sta.getip() == nil) and (counter > counter_max) then
            tmr.stop(0)
            ledOn()
            print("\nStarting as AP to configure network...")
            dofile("wifi_setup.lua")
        elseif wifi.sta.getip() ~= nil then
            tmr.stop(0)
            ip, nm, gw=wifi.sta.getip()
            print("\nConnected...")
            print("\n\tIP Address: ", ip)
            print("\n\tNetmask: ", nm)
            print("\n\tGateway Addr: ", gw)
            if (file.exists("app.lua")) then
                print('\nRunning app.lua after 10s....')
                tmr.alarm(1, 10000, 0, function() dofile("app.lua") end);
                return
            end
            print('\napp.lua doesnt exist....')
        end
        counter = counter + 1
    end)
end

print('\nRunning init.lua\n')

connectWifi()

print("---")
print("Boot reason:")
print(node.bootreason())
print("---")
print("Heap cleaned: "..collectgarbage())
print("---")
