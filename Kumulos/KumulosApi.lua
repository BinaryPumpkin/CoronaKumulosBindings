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