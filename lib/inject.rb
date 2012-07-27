#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'yaml'

LOCAL = YAML.load_file("../config/local.yml")

if ENV["RAILS_ENV"] == "production"
	url = URI.parse("http://#{LOCAL['production_server']}/messages")
else
	url = URI.parse('http://localhost:3000/messages')
end
puts url
http = Net::HTTP.new(url.host, url.port)
data = "<message>
	<importance></importance>
	<body>ACKNOWLEDGEMENT: SSH is normal</body>
	<sender>#{LOCAL['testing_email']}</sender>
	<uid></uid>
	<subject>PROBLEM for SSH</subject>
	<recipients_direct>#{LOCAL['production_user']}</recipients_direct>
	<recipients_indirect></recipients_indirect>
	<stamp>#{DateTime::now}</stamp>
	<keywords>Infrastructure</keywords>
	</message>"
headers = { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml' }
res = http.start do |con|
	con.post(url.path, data, headers)
end
puts res.to_yaml
