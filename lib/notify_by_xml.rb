#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'optparse'
require 'date'

# Change "server.com" here and below to reflect the server ComHub is running on.
url = URI.parse('http://domain.com/messages')

log = File.open("/var/lib/nagios/notify_by_xml.log", "a")
log.puts "#{ARGV.join(' ')}"
log.close

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: notify_host_by_xml.rb [options]"
	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
	options[:timestamp] = Date.new
	opts.on("-d", "--timestamp ", "Timestamp from origination") do |d|
		options[:timestamp] = d
	end
	options[:type] = nil
	opts.on("-t", "--type TYPE", "Type of alert") do |t|
		options[:type] = t
	end
	options[:host] = nil
	opts.on("-h", "--host HOST", "Specify host generating alert") do |h|
		options[:host] = h
	end
	options[:state] = nil
	opts.on("-u", "--state STATE", "Specify host state") do |u|
		options[:state] = u
	end
	options[:address] = nil
	opts.on("-a", "--address ADDRESS", "Specify host address") do |a|
		options[:address] = a
	end
	#options[:info] = nil
	#opts.on("-i", "--info INFO", "Actual content of alert") do |i|
	#	options[:info] = i
	#end
	options[:keywords] = nil
	opts.on("-k", "--keywords ", "Comma-delimited list of keywords") do |x|
		options[:keywords] = x
	end
	options[:recipients] = nil
	opts.on("-r", "--recipients ", "Comma-delimited recipients list") do |r|
		options[:recipients] = r
	end
	options[:service] = nil
	opts.on("-s", "--service [SERVICE]", "Specify affected service") do |s|
		options[:service] = s
	end
end.parse!

http = Net::HTTP.new(url.host, url.port)
if options[:service]
	summary = "#{options[:type]}: #{options[:service]} on #{options[:host]} (#{options[:address]}) is #{options[:state]}!"
	subject = "#{options[:type]} for #{options[:service]}"
else
	summary = "#{options[:type]}: #{options[:host]} (#{options[:address]}) is #{options[:state]}!"
	subject = "#{options[:type]} for #{options[:host]}"
end
data = "<message>
  <body>#{summary}\n#{ARGV.join(" ")}</body>
  <sender>comhub@domain.com</sender>
  <uid></uid>
  <subject>#{subject}</subject>
  <recipients_direct>#{options[:recipients]}</recipients_direct>
  <stamp>#{options[:timestamp]}</stamp>
  <keywords>#{options[:keywords]}</keywords>
  </message>"
headers = { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml' }
res = http.start do |con|
  con.post(url.path, data, headers)
end
