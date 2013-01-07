#!/usr/bin/env ruby -wKU
require "net/http"
require "uri"
require "pp"

params = {
  :address_name => "Real Man",
  :address_street => 'line_1',
  :address_city => 'Hometown',
  :address_state => 'MI',
  :address_zip => '49508',
  :payer_email => 'ed@example.com',
  :payment_type => 'visa',
  :custom => "#{ARGV[0]}"
}

url="http://localhost:3000/sign_products/process_purchase"

res = Net::HTTP.post_form URI.parse(url), params

pp res

