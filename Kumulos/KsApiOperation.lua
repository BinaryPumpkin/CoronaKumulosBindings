--[[
Copyright (c) 2013 Binary Pumpkin Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local crypto    = require "crypto"
local json      = require "json"

KsApiOperation          = {};
KsApiOperation.__index  = KsApiOperation;

function KsApiOperation.create(sessionToken, apiKey, secretKey, methodName, params)
    
    local newOp = {};
    newOp.mSessionToken     = sessionToken;
    newOp.mApiKey           = apiKey;
    newOp.mSecretKey        = secretKey;
    newOp.mMethodName       = methodName;
    newOp.mParams           = params;
    newOp.mApiUrl           = "https://api.kumulos.com/b2.2/" ..apiKey.. "/" ..methodName.. ".json";
    
    setmetatable(newOp,KsApiOperation);
    return newOp;
end

function KsApiOperation:getParams()
    
    -- BM: Generate the salt and hashedKey using the secret key, for security.
    local salt      = math.random(9999999);
    local hashedKey = crypto.digest( crypto.md5, self.mSecretKey .. salt )
    
    -- BM: Prime the postData with the salt and hashedKey
    local postData  = "hashedKey=" ..hashedKey.. "&salt=" ..salt;
    
    -- BM: deviceType 7 means 'lua'
    postData = postData .. "&deviceType=7&bindingVersion=0.1";
    
    -- BM: If we have a session token, add it in!
    if ( self.mSessionToken ~= nil and self.mSessionToken ~= "" ) then
        postData = postData .. "&sessionToken=" .. self.mSessionToken
    end
    
    -- BM: Need to loop over the params and add them to the postData string.
    for k, v in pairs(self.mParams) do
        postData = postData .. "&params[" .. tostring(k) .. "]=" .. tostring(v)
    end    
    
    -- BM: Not entirely sure that the headers are needed, lets add them for completeness.
    local headers               = {}
    headers["Content-Type"]     = "application/x-www-form-urlencoded"
    headers["Content-Length"]   = string.len( postData )
    
    -- BM: Build params table
    local params     = {};
    params.body      = postData;
    params.headers   = headers;
    
    -- BM: Erm ... think you can work out this :)
    return params;
end 

local function createCompleteHandler( ksOperation )
    
    local localOperation = ksOperation;
    
    return function (event)
        
        local returnVal = {};
        
        if ( event == nil ) then
            returnVal.isError   = true
            returnVal.Error     = "nil event"
        elseif ( event.isError ) then
            returnVal.isError   = true
            returnVal.Error     = "ksApiOperation error"
        else
            local response = json.decode( event.response );
            if ( response == nil ) then 
                returnVal.isError   = true
                returnVal.Error     = "json decode error"
            else
                --[[
                local resMessage = response.responseMessage;
                if ( resMessage ~= nil ) then
                    local code              = response.responseCode;
                    local processingTime    = response.requestProcessingTime or 0;
                    print(  "KsApiOperation: " ..localOperation.mMethodName .. 
                            ": ResponseCode: " .. code ..
                            " ResponseMessage: " .. resMessage ..
                            " requestProcessingTime: " .. processingTime )
                end
                --]]

                if ( response.sessionToken ) then
                    KumulosApi.SetSessionToken(response.sessionToken, response.timestamp);
                end
                
                returnVal = response.payload;
            end
        end
        
        if ( localOperation.mCallback ~= nil ) then
            localOperation.mCallback(returnVal);
        end
    end
end

function KsApiOperation:executeWWWRequest(callback)
    
    self.mCallback = callback;
  
    local params = self:getParams();
    network.request( self.mApiUrl, "POST", createCompleteHandler(self), params );
  
end