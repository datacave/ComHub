# == Schema Information
# Schema version: 20101206175716
#
# Table name: acknowledgments
#
#  id              :integer(4)      not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  body            :string(255)
#  uid             :string(255)
#  to              :string(255)
#  status          :string(255)
#  from            :string(255)
#  notification_id :integer(4)
#

class Acknowledgment < ActiveRecord::Base
	belongs_to :notification

	after_create :suppressionate

	def suppressionate # To keep from monkey-patching "suppress"

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
      # Suppress these kinds of messages
      code = body.strip
      c = Channel.find_by_address(from)
      # Probably ought to be a time limit on this.
      n = Notification.find_last_by_channel_id_and_code(c.id, code)
      unless n.nil?
        update_attributes(:notification_id => n.id)
        notification.acknowledge!

        # Need to send an ack to the Nagios server, which will in turn send out another
        # notification that the problem has been ack'd. Will this get throttled?...
        #
        #  cmd_typ=
        #  23 service notifications off
        #  22 service notifications on
        #  24 host notifications on
        #  33 host ack
        #  34 service ack
        #  51 removes host ack
        #  52 removes service ack
        #
        #  wget -O - --http-user=username --http-password=password --post-data
        #   'cmd_typ=34&cmd_mod=2&host=server_xyz&service=SSH&sticky_ack=on&
        #   send_notification=on&com_data=asdf&btnSubmit=Commit#'
        #   http://nagios.internal.com/nagios3/cgi-bin/cmd.cgi

        if m = notification.body.match(/PROBLEM: (.*) on (\S+) \(/)
          service = m[1]
          host = m[2]
          url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=34&cmd_mod=2&host=" +
            "#{host}&service=#{service.gsub(/ /, "%20")}&sticky_ack=on&" +
            "send_notification=on&com_data=Comhub%20was%20here&btnSubmit=Commit"
        elsif m = notification.body.match(/PROBLEM: (\w+) \(/)
          host = m[1]
          url = "/nagios3/cgi-bin/cmd.cgi?cmd_typ=33&cmd_mod=2&host=#{host}" +
            "&sticky_ack=on&send_notification=on&com_data=Comhub%20was%20here&btnSubmit=Commit"
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
    rescue Exception => e
      logger.error("Error: #{$!} -- " + e.inspect)
    end


	end

end
