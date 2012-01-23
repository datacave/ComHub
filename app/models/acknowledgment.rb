# == Schema Information
# Schema version: 20101206175716
#
# Table name: acknowledgments
#
#	id							:integer(4)			not null, primary key
#	created_at			:datetime
#	updated_at			:datetime
#	body						:string(255)
#	uid						 :string(255)
#	to							:string(255)
#	status					:string(255)
#	from						:string(255)
#	notification_id :integer(4)
#

class Acknowledgment < ActiveRecord::Base
	belongs_to :notification

	after_create :suppressionate

	def suppressionate # Named wierdly to keep from monkey-patching "suppress"

		require 'net/https'
		require 'uri'
		
#		# Suppress the receiving channel
#		@channel = Channel.find_by_address(params[:From])
#		unless @channel.nil?
#			@ack.notification = Notification.find_last_by_channel_id_and_code(@channel.id,
#				code)
#			@channel.suppressed = DateTime.now
#			@channel.save
#		else
#			logger.error("Channel #{params[:To]} was not found!")
#		end

		begin

			logger.error("Suppressing...")
			text = body.strip
			code = text[0..2]
			logger.error(code)
			
			if m = code.match(/^Op([0-9])$/)
				url = "/open" + m[1]
				logger.error(url)
				u = URI.parse("http://" + LOCAL['arduino_server'] + url)
				logger.error(u.inspect)
				http = Net::HTTP.new(u.host, u.port)
				req = Net::HTTP::Get.new(u.request_uri)
				res = http.request(req)
				logger.info(res.body)

			else
				with_service = false
				with_prejudice = false
				t = Time.now
				hr = t.hour
				blackout = 6
				if text.length > 3
					if text[3] == 33 # `!' in ASCII. I don't know why we're dealing with codes.
						logger.error("... with service.")
						with_service = true
						if hr > 17 && hr < 1
							if hr > 8
								blackout = 24 - hr + 8
							else
								blackout = 8 - hr
							end
						end
					elsif text[3] == 36 # `$'
						logger.error("... with prejudice")
						with_prejudice = true
					end
				end
				c = Channel.find_by_address(from)
				# Probably ought to be a time limit on this.
				n = Notification.find_last_by_channel_id_and_code(c.id, code)
				unless n.nil?
					update_attributes(:notification_id => n.id)
					notification.acknowledge!

					# Need to send an ack to the Nagios server, which will in turn send out another
					# notification that the problem has been ack'd. Will this get throttled?...
					#
					#	cmd_typ=
					#	22 service notifications on
					#	23 service notifications off
					#	24 host notifications on
					#	25 host notifications off
					#	29 ALL service notifications off (with option on host)
					#	33 host ack
					#	34 service ack
					#	51 removes host ack
					#	52 removes service ack
					#	55 schedules downtime for host
					#	56 schedules downtime for service
					#
					#	wget -O - --http-user=username --http-password=password --post-data
					#	 'cmd_typ=34&cmd_mod=2&host=server_xyz&service=SSH&sticky_ack=on&
					#	 send_notification=on&com_data=asdf&btnSubmit=Commit'
					#	 http://nagios.internal.com/nagios3/cgi-bin/cmd.cgi
					#
					#	wget -O - --no-check-certificate --http-user=username --http-password=password
					#	 --post-data 'cmd_typ=55&cmd_mod=2&host=server_xyz&
					#	 com_author=ComHub&com_data=ComHub%20was%20here&
					#	 start_time=2011-12-21%2009%3A50%3A00&
					#	 end_time=2011-12-21%2011%3A50%3A00&
					#	 fixed=0&hours=4&minutes=15&btnSubmit=Commit'
					#	 http://nagios.internal.com/nagios3/cgi-bin/cmd.cgi

					if m = notification.body.match(/PROBLEM: (.*) on (\S+) \(/)
						service = m[1]
						host = m[2]
						if with_service
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=56&cmd_mod=2&host=#{host}&" +
								"service=#{service.gsub(/ /, "%20")}&" +
								"com_author=ComHub&com_data=Comhub%20was%20here&" +
								"start_time=" + URI.escape(t.to_s(:db)) + "&" +
								"end_time=" + URI.escape((t + 2.hours).to_s(:db)) + "&" +
								"fixed=0&hours=" + blackout.to_s + "&minutes=0&btnSubmit=Commit"
						elsif with_prejudice
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=23&cmd_mod=2&host=#{host}&" +
								"service=#{service.gsub(/ /, "%20")}&btnSubmit=Commit"
						else
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=34&cmd_mod=2&host=" +
								"#{host}&service=#{service.gsub(/ /, "%20")}&sticky_ack=on&" +
								"send_notification=on&com_author=ComHub&" +
								"com_data=Comhub%20was%20here&btnSubmit=Commit"
						end
					elsif m = notification.body.match(/PROBLEM: (\w+) \(/)
						host = m[1]
						if with_service
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=55&cmd_mod=2&host=#{host}&" +
								"com_author=ComHub&com_data=Comhub%20was%20here&" +
								"start_time=" + URI.escape(t.to_s(:db)) + "&" +
								"end_time=" + URI.escape((t + 2.hours).to_s(:db)) + "&" +
								"fixed=0&hours=" + blackout.to_s + "&minutes=0&btnSubmit=Commit"
						elsif with_prejudice
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=25&cmd_mod=2&host=#{host}&" +
								"btnSubmit=Commit"
						else
							url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=33&cmd_mod=2&host=#{host}" +
								"&sticky_ack=on&send_notification=on&com_author=ComHub&" +
								"com_data=Comhub%20was%20here&btnSubmit=Commit"
						end
					end
					u = URI.parse("https://" + LOCAL['nagios_server'] + url)
					logger.error(u.inspect)
					http = Net::HTTP.new(u.host, u.port)
					http.use_ssl = true
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					req = Net::HTTP::Get.new(u.request_uri)
					req.basic_auth(LOCAL['nagios_username'], LOCAL['nagios_password'])
					res = http.request(req)
					logger.info(res.body)

				else
					logger.error("Couldn't find notification with code #{code} to suppress!")
				end
			end
		rescue Exception => e
			logger.error("Error: #{$!} -- " + e.inspect)
		end

	end

end
