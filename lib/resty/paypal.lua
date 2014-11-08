
local setmetatable = setmetatable
local pairs = pairs
local ngx = ngx


local _M = {}
_M._VERSION = '0.10'

local mt = { __index = _M }
local prod_endpoint = 'https://api-3t.paypal.com/nvp'
local sandbox_endpoint = 'https://api-3t.sandbox.paypal.com/nvp'
local prod_url = 'https://www.paypal.com/webscr?cmd=_express-checkout&useraction=commit&token='
local sandbox_url = 'https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&useraction=commit&token='


function _M:new(environment, _user, _pwd, _signature)
    local http = require("resty.http").new()
    
    if not http then
        return nil
    end
    
    if environment == "prod" then
        return setmetatable({ errors = {}, http = http, endpoint = prod_endpoint, paypalurl = prod_url, user = _user, pwd = _pwd, signature = _signature }, mt)
    else
        return setmetatable({ errors = {}, http = http, endpoint = sandbox_endpoint, paypalurl = sandbox_url, user = _user, pwd = _pwd, signature = _signature }, mt)
    end

end

function _M:request(_method, _params)
    
    local params = {}
    params.METHOD = _method
    params.VERSION = '74.0'
    params.USER = self.user
    params.SIGNATURE = self.signature
    params.PWD = self.pwd

    for k,v in pairs(_params) do params[k] = v end
        
    local http_params = ngx.encode_args(params)
    
    
    local res, err = self.http:request_uri(self.endpoint, {
        method = "POST",
        body = http_params,
        headers = {
          --["Content-Type"] = "application/x-www-form-urlencoded",
        },
	ssl_verify = false
      })

    if not res then
        return nil, "failed to request: " .. err
    end

    local http_result = ngx.decode_args(res.body)
      
      
    if((http_result['ACK'] == 'Success' or http_result['ACK'] == 'SuccessWithWarning') and _method == 'SetExpressCheckout') then --Connexion à l'API paypal réussie
	return self.paypalurl .. http_result['TOKEN'], nil
			
    elseif((http_result['ACK'] == 'Success' or http_result['ACK'] == 'SuccessWithWarning') and _method ~= 'SetExpressCheckout') then --Connexion à l'API paypal réussie
	return http_result, nil

    else
	--Message erreur paypal
	self.errors = http_result
	return nil, self.errors
    end
end

return _M