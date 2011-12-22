#!/usr/bin/env ruby
require 'net/https'
require 'uri'
require 'yaml'

LOCAL = YAML.load_file("../config/local.yml")

if ENV["RAILS_ENV"] == "production"
	url = URI.parse("https://#{LOCAL['production_server']}/acknowledgments/remote")
else
	url = URI.parse('http://localhost:3000/acknowledgments/remote')
end
puts url
http = Net::HTTP.new(url.host, url.port)
if ENV["RAILS_ENV"] == "production"
	http.use_ssl = true
else
	http.use_ssl = false
end
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
data = "Body=Xxx!&To=#{LOCAL['twilio_number']}&From=#{LOCAL['testing_phone']}&SmsStatus=received&SmsSid=asdf&SmsMessageSid=qwer&AccountSid=AC6524b76ade95cfec0c693cc0c53b7176&ApiVersion=2008-08-01&FromCity=COLUMBUS&FromState=IN&FromZip=47203&FromCountry=US&ToCity=MCCUTCHANVILLE&ToState=IN&ToZip=47711&ToCountry=US"
res = http.start do |con|
	con.post(url.path, data)
end
puts res.to_yaml
