#!/usr/bin/env ruby -wKU
require "net/http"

http = Net::HTTP.new('127.0.0.1', 3000)

q = "id=4"
path = "/sign_products/add_to_cart?" + q

# GET request -> so the host can set his cookies
resp, data = http.get path #, q

cookie = resp.response['set-cookie']

p resp
p cookie

sleep 1

headers = {
  'Cookie' => cookie,
  'Referer' => 'http://paypal.com',
  'Content-Type' => 'application/x-www-form-urlencoded'
}
path = '/sign_products/process_purchase'
q = "address_city=Hometown&address_name=Tester&address_state=MI&address_street=line_1&address_zip=49508&payer_email=ed%40example.com&payment_type=visa&verify_sign=true"
#  POST from Paypal
resp, data = http.post(path, q, headers)
p resp



