# End device scripts compatible with d-of-Things

End devices compatible with d-of-Things system are devided into:
- Active - Switches. Turn on the lamp. They don't sleep
- Passive - Sensors. Wake up get sensor data. Sleep 5mins
- Trigger based - SensorTriggers - something happened - notify                                          

Dir structure:
```lua
├── core # ESP8266 core functions
│   ├── functions.lua
│   ├── init.lua
│   ├── mqtt.lua # MQTT server configuration user/password
│   ├── post.lua
│   ├── wificonfig.lua # WiFi configuration
│   └── wifi_setup.lua 
├── active # Active devices
│   └── smartsocket
│       ├── app.lua
│       └── config.lua # Active device configuration
├── passive # Passive devices
│   ├── app.lua
│   └── config.lua # Passive device configuration
├── README.md
├── LICENCE
├── test # Examples for pushing to the system
│   ├── push.sh
│   └── request.txt
└── triggers # Trigger devices
    ├── app.lua
    └── config.lua  # Trigger device configuration
```
 
# Requirements:
ESP8266 boards should be flashed with NodeMCU firmware

# Installation:
1) Flash ESP8266 boards with NodeMCU firmware with enabled MQTT module
   modules
2) Choose between 1 of the 3 devices - Active, Passive, Trigger
3) Create Feed and Key iin d-of-things system.
4) Update:
   - Its config.lua script with proper - Feed, Key, User, Password
   - wificonfig.lua with your WiFi details
   - mqtt.lua with your MQTT server address, user and password.
5) Upload:
   - core dir
   - chosen device - active, password or trigger
5.1) If wificonfig.lua isn't configured then device starts as AP, so 
     connect to it through your mobile phone, setup the WIFI of your home 
     network and it is ready to connect.
6) Reboot ESP8266 boards and check dofthings web interface for data updates

# License
The MIT License

Copyright 2014-present Boyan Vladinov <nayobix@nayobix.org>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
