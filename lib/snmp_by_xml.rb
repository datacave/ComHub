#!/usr/bin/env ruby

# Called from SNMPTT like this:
#EXEC /usr/lib/nagios/plugins/contrib/snmp_by_xml.rb --subject $N --importance $s
#
# I used something like this to prepare all the traps from my mibs
#!/bin/bash
#echo $1
#MIBDIRS=/usr/share/snmp/mibs:/etc/snmp/mibs/cisco:/etc/snmp/mibs/liebert:/etc/snmp/mibs/hp:/etc/snmp/mibs/activepower:/etc/snmp/mibs/eaton:/etc/snmp/mibs/enersure
#MIBS=ALL
#for i in $1
#	do
#	/usr/sbin/snmpttconvertmib --in=$i --out=/etc/snmp/snmptt.conf.raw --net_snmp_perl --exec='/etc/snmp/snmp_by_xml.rb --address $aA --subject $N --importance $s'
#done

require 'net/http'
require 'uri'
require 'optparse'
require 'date'
require 'yaml'

url = URI.parse('http://domain.com/messages')
timestamp = Date.new.strftime("%c")

log = File.open("/var/lib/snmp/snmp_by_xml.log", "a")
log.puts "#{timestamp}: #{ARGV.join(' ')}"
log.close

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: notify_host_by_xml.rb [options]"
	opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
		options[:verbose] = v
	end
	options[:subject] = nil
	opts.on("-s", "--subject ", "Short description") do |s|
		options[:subject] = s
	end
	options[:importance] = nil
	opts.on("-i", "--importance ", "Severity of the trap") do |i|
		options[:importance] = i
	end
	options[:address] = nil
	opts.on("-a", "--address ", "IP address of the agent") do |a|
		options[:address] = a
	end
end.parse!

keywords = case options[:address]
	when /10\.1\.9/
		'Keyword1'
	when /10\.1\.25/, /10\.1\.26/
		'Keyword2'
	when /10\.1\.31/
		'Keyword3'
	else
		'Generic'
end

http = Net::HTTP.new(url.host, url.port)
data = "<message>
  <body>#{options[:address]} - #{options[:subject]} - #{ARGV.join(" ")}</body>
  <sender>snmptt@nagios.data-cave.com</sender>
  <subject>SNMP Trap: #{options[:subject]}</subject>
  <recipients_direct>everybody</recipients_direct>
  <stamp>#{timestamp}</stamp>
  <keywords>#{keywords}</keywords>
	<importance>#{options[:importance]}</importance>
  </message>"
headers = { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml' }
res = http.start do |con|
  con.post(url.path, data, headers)
end

puts res.to_yaml
