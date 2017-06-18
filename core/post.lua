---------------------------------------------
--Module for posting to d-of-things server---
---------------------------------------------

local moduleName = ...
local M = {}
_G[moduleName] = M

--Post server details
--local iHost = "10.0.0.10"
local iHost = "172.22.152.80"
local iPort = 80
--local iPort = 18080
local iHostPort = "http://"..iHost..":"..iPort
local iUri = "/dataPush/push"
local iAuthBasic = "Ym95YW46cXcyd2UzZXI0=="
local iSecure = 0

function getHttpHeaders(json)

    print("Http post request form: "..json)
    headers = " HTTP/1.1\r\n"
    .. "Content-Type: application/json\r\n"
    .. "Authorization: Basic "..iAuthBasic.."\r\n"
    .. "Host: "..iHost.."\r\n"
    .. "Connection: close\r\n"
    .. "Accept: */*\r\n"
    .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"

    return headers
end

--
--Client post interface. Posts json to server end point
--
function M.clientPost(json)

	print("clientPost call...")
	headers = getHttpHeaders(json);
	feed_uri = iUri..""..feed
	request_uri = iHostPort..""..feed_uri..""
	print("\nrequest_uri..."..request_uri)
	print("\nheaders..."..headers)


	http.post(request_uri,
		  headers,
		  ''..json..'',
		  function(code, data)
			if (code < 0) then
				print("HTTP request failed:"..code)
			else
				print(code, data)
    			end
			node.task.post(reqConsumer);
		  end
		)

collectgarbage()
end

return M
