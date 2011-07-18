#!/usr/bin/env ruby
require 'net/https'
require 'uri'
require 'yaml'

LOCAL = YAML.load_file("../config/local.yml")

if ENV["RAILS_ENV"] == "production"
	url = URI.parse("https://#{LOCAL['production_server']}/acknowledgments/remote")
else
	url = URI.parse('https://localhost:3000/acknowledgments/remote')
end
puts url
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
data = "<acknowledgment>
	<Body>Xxx</Body>
  <To>comhub@#{LOCAL['production_domain']}.com</To>
	<From>#{LOCAL['testing_email']}</From>
	<SmsStatus>received</SmsStatus>
	<SmsSid>asdf</SmsSid>
	</acknowledgment>"
headers = { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml' }
res = http.start do |con|
	con.post(url.path, data, headers)
end
puts res.to_yaml
