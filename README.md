# lua-resty-paypal

Lua Paypal client using express checkout for [OpenResty](http://openresty.org/) / [ngx_lua](https://github.com/chaoslawful/lua-nginx-module).

# Status

Ready for testing. Probably production ready in most cases, though not yet proven in the wild. Please check the issues list and let me know if you have any problems / questions.

# Requirements

* https://github.com/pintsized/lua-resty-http

# Features

* Express checkout method (https://developer.paypal.com/docs/classic/express-checkout/gs_expresscheckout/)


# API

* [new](#name)
* [request](#request)



## Synopsis

```` lua
lua_package_path "/path/to/lua-resty-paypal/lib/?.lua;;";

server {


  location /Shop/payment {
    resolver 8.8.8.8;  # use Google's open DNS server for an example

    content_by_lua '
      local paypal = require("resty.paypal"):new("dev", "paypal_user", "paypal_pwd", "api_signature")

      local totalPrice = 150
      local params = { 
	      RETURNURL = config.server_name .. "/Shop/PaymentCallback",
	      CANCELURL = config.server_name .. "/Shop/cancelURL",
	      PAYMENTREQUEST_0_AMT = totalPrice,
	      PAYMENTREQUEST_0_CURRENCYCODE = "EUR",
	      PAYMENTREQUEST_0_ITEMAMT = itemPrice0,
	      L_PAYMENTREQUEST_0_NAME00 = "Item name 0",
	      L_PAYMENTREQUEST_0_DESC00 = "Description 0",
	      L_PAYMENTREQUEST_0_AMT00 = itemPrice0,
	      L_PAYMENTREQUEST_0_QTY00 = 1,
	      NOSHIPPING = 1
      }

      --Get payment link
      local response, err = paypal:request("SetExpressCheckout", params)
    ';
  }


  location /Shop/PaymentCallback {
    resolver 8.8.8.8;  # use Google's open DNS server for an example

    content_by_lua '
      local paypal = require("resty.paypal"):new("dev", "paypal_user", "paypal_pwd", "api_signature")

      --Get Paypal context
      local response, err = paypal:request("GetExpressCheckoutDetails", {TOKEN = ngx.var.token})

      local totalPrice = 150
      local params = { 
	      CANCELURL = config.server_name .. "/Shop/cancelURL",
	      PAYMENTREQUEST_0_AMT = response["PAYMENTREQUEST_0_AMT"],
	      PAYMENTREQUEST_0_CURRENCYCODE = "EUR",
	      PAYMENTREQUEST_0_ITEMAMT = totalPrice,
	      L_PAYMENTREQUEST_0_NAME00 = "Item name 0",
	      L_PAYMENTREQUEST_0_DESC00 = "Description 0",
	      L_PAYMENTREQUEST_0_AMT00 = totalPrice,
	      L_PAYMENTREQUEST_0_QTY00 = 1,
	      TOKEN = ngx.var.token,
	      PAYERID = ngx.var.PayerID,
	      PAYMENTACTION = "Sale",
	      NOSHIPPING = 1
      }

      -- Order payment
      local response, err = paypal:request("DoExpressCheckoutPayment", params)

    ';
  }
}
````

# Methods

## new

`syntax: paypal = paypal:new(environment, paypal_user, paypal_pwd, api_signature)`

Creates the paypal object. In case of failures, returns `nil` and a string describing the error.
environment = "prod" or "dev"

## request

`syntax: response, err = paypal:request(method, params)`

Request Paypal with an https connection. In case of failures, returns `nil` and a string describing the error.
For basic usage:
method = "SetExpressCheckout" or method = "GetExpressCheckoutDetails" or method = "DoExpressCheckoutPayment"
params: table containing parameters needed by Paypal for the requested method.

# Author

Lucas Lafon <chidori_on@hotmail.fr>

# Licence

This module is licensed under the 2-clause BSD license.

Copyright (c) 2014, Lucas Lafon <chidori_on@hotmail.fr>

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
