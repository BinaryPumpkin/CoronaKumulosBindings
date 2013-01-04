--[[
Copyright (c) 2013 Binary Pumpkin Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require("Kumulos.KsApiOperation");

KumulosApi                  = {};
KumulosApi.mAPIKey          = "YOUR_API_KEY"
KumulosApi.mSecretKey       = "YOUR_SECRET_KEY"
KumulosApi.mSessionToken    = ""
KumulosApi.timeStamp        = 0

function KumulosApi.SetSessionToken(token, newTimeStamp)
    KumulosApi.mSessionToken      = token;
    KumulosApi.timeStamp          = newTimeStamp;
end

function KumulosApi.ExecuteRequest(callbackFunc, methodName, params)
    local apiOperation = _G.KsApiOperation.create(KumulosApi.mSessionToken, KumulosApi.mAPIKey, KumulosApi.mSecretKey, methodName, params);
    apiOperation:executeWWWRequest(callbackFunc);
end

--
-- BM: Add your methods here that mirror those you create on kumulos.com, see examples below
--

-- BM: This example has two parameters
function KumulosApi.exampleMethod(callbackFunc, exampleParameter1, exampleParameter2)
    local params = {}
    params["exampleParameter1"] = exampleParameter1
    params["exampleParameter2"] = exampleParameter2
    KumulosApi.ExecuteRequest(callbackFunc, "exampleMethod", params);
end

-- BM: This example has no parameters
function KumulosApi.exampleMethod2(callbackFunc)
    local params = {}
    KumulosApi.ExecuteRequest(callbackFunc, "exampleMethod2", params);
end