# == Schema Information
# Schema version: 20101206175716
#
# Table name: notifications
#
#	id				 :integer(4)			not null, primary key
#	created_at :datetime
#	updated_at :datetime
#	sender		 :string(255)
#	subject		:string(255)
#	body			 :text
#	importance :integer(4)
#	message_id :integer(4)
#	keywords	 :text
#	channel_id :integer(4)
#	state			:string(255)		 default("created")
#	code			 :string(255)
#	uid				:string(255)
#

class Notification < ActiveRecord::Base

	belongs_to :message
	belongs_to :channel
	has_one :mechanism, :through => :channel
	has_many :acknowledgments, :dependent => :destroy

	acts_as_state_machine :initial => :created

	state :created
	state :sent
	state :delivered
	state :confirmed
	state :acknowledged

	event :send_via do
		transitions :to => :sent, :from => :created
	end

	event :deliver do
		transitions :to => :delivered, :from => :sent
	end

	event :confirm do
		transitions :to => :confirmed, :from => :delivered
	end

	event :acknowledge do
		transitions :to => :acknowledged, :from => [ :delivered, :confirmed ]
	end

	states.each { |s| named_scope s, :conditions => { :state => s.to_s } }

	def self.apportion(message, contacts)
		code = Notification.generate_code
		contacts.each do |contact|
			keywords = message.keywords.split(/, ?/)
			# Gotta be a better way than this. Now relying on nil keywords being
			# ignored by the contact, which is a change from sending on anything
			# that has no keywords. Which is probably fine, since everything in
			# our system should be keyworded now.
			keywords = message.keywords.split(/, ?/).select { |k|
				Keyword.find_by_designation(k).in_play? }
			logger.info("*****************************")
			logger.info("Contact: #{contact.inspect}")
			logger.info("Keywords: #{keywords}")
			logger.info("Contact enabled?: #{contact.enabled?}")
			logger.info("Contact on_call?: #{contact.on_call?}")
			logger.info("Contact subscribed?: #{contact.subscribed?(keywords)}")
			logger.info("Contact filtering?: #{contact.filtering?(message.body)}")
			logger.info("Message important?: #{message.important?}")
			if contact.enabled? && contact.on_call? &&
				contact.subscribed?(keywords) && !contact.filtering?(message.body) &&
				message.important?
				contact.channels.active.each do |channel|
					if channel.in_play?
						if channel.mechanism.designation == "sms"
							# Total length must be <= 160.
							if message.body.match(/^PROBLEM/) &&
									message.sender.match(/nagios/)
								text = message.body[0,154] + " (#{code})"
							else
								text = message.body[0,160]
							end
						else
							if message.body.match(/^PROBLEM/) &&
									message.sender.match(/nagios/)
								text = message.body + " (#{code})"
							else
								text = message.body
							end
						end
						notification = Notification.create(
							:body => text,
							:channel_id => channel.id,
							:sender => LOCAL['return_address'],
							:subject => message.subject,
							:importance => message.importance,
							:keywords => keywords.join(", "),
							:message => message,
							:code => code
						)
						notification.send_via_mechanism
					end
				end
			end
		end
	end

	def send_via_mechanism
		self.send_via!
		self.send("send_via_#{self.channel.mechanism.designation}")
	end

	def send_via_smtp
		smtp = Net::SMTP.start(LOCAL['development']['server'], 25)
		msg = ""
		msg << "From: ComHub <#{LOCAL['return_address']}>\n"
		msg << "To: #{channel.address}\n"
		msg << "Subject: #{subject}\n"
		msg << "X-Priority: 1\n" if importance
		# There needs to be a blank line in here to trigger the actual
		# start of the body of the message.
		msg << "\n"
		msg << body
		begin
			smtp.send_message msg, LOCAL['return_address'], channel.address
		rescue
			logger.error("Failed to send notification #{id} via SMTP!")
		else
			self.deliver!
		end
		smtp.finish
	end

	def send_via_sms
		# This is a local library
		require 'twiliolib'
		api_version = LOCAL['twilio_version']
		account_sid = LOCAL['twilio_sid']
		account_token = LOCAL['twilio_token']
		if (body.match(/^ACKNOWLEDGEMENT/))
			number = LOCAL['twilio_number2']
		else
			number = LOCAL['twilio_number']
		end
		account = Twilio::RestAccount.new(account_sid, account_token)
		data = {
			'From' => number,
			'To' => channel.address,
			'Body' => body,
			'StatusCallback' => LOCAL['return_url']
		}
		response = account.request("/#{api_version}/Accounts/#{account_sid}/SMS/Messages",
			'POST', data)
		unless response.kind_of? Net::HTTPSuccess
			logger.error("Got error #{response.to_yaml} from Twilio!")
		else
			self.update_attributes(:uid => response.body.match(/<Sid>([^<]*)<\/Sid>/)[1])
			self.deliver!
		end
	end

	def send_via_xmpp
		# This is a local package on Ubuntu
		require 'xmpp4r'
		jid = Jabber::JID.new(LOCAL['jabber_account'])
		pw = LOCAL['jabber_password']
		cl = Jabber::Client.new(jid)
		cl.connect(LOCAL['jabber_server'], 5222)
		cl.auth(pw)
		m = Jabber::Message.new(channel.address,
			keywords + ": " + body).set_type(:normal).set_id('1').set_subject(subject)
		# Need a better test to see if the message went through, but `send' doesn't
		# return anything...
		cl.send(m)
		cl.close
		self.deliver!
	end

	# I can't get mumbles_0.4-1 to receive messages from over the network
	# on my Ubuntu box, so I can't test this yet.
	def send_via_post
		# This is a gem, from here:
		# http://ruby-growl.rubyforge.org/ruby-growl/README_txt.html
		require 'ruby-growl'
		# Maybe use the channel address field as the "host/password"?...
		g = Growl.new(channel.address.split(/\//)[0], 'ComHub', ['ComHub'],
			['ComHub'], channel.address.split(/\//)[1])
		g.notify(['ComHub'], subject, body, "ComHub")
		self.deliver!
	end

	def send_via_voice
		# This is a local gem
		require 'twilio-ruby'
		api_version = LOCAL['twilio_version']
		account_sid = LOCAL['twilio_sid']
		account_token = LOCAL['twilio_token']
		if (body.match(/^ACKNOWLEDGEMENT/))
			number = LOCAL['twilio_number2']
		else
			number = LOCAL['twilio_number']
		end
		client = Twilio::REST::Client.new(account_sid, account_token)
		call = client.account.calls.create({:from => number, :to => channel.address,
			:url => URI::escape("#{LOCAL['return_twiml']}?message=#{body}"),
			:status_callback => LOCAL['return_url'] })
		if call.status == 'failed'
			logger.error("Got error #{call.to_yaml} from Twilio!")
		else
			self.update_attributes(:uid => call.sid)
			self.deliver!
		end
	end

	def self.generate_code
		#alpha1 = ((1 + rand(26)) + 64).chr
		#alpha2 = ((1 + rand(26)) + 96).chr
		#alpha3 = ((1 + rand(26)) + 96).chr
		#"#{alpha1}#{alpha2}#{alpha3}"
		numeric1 = (1 + rand(9))
		numeric2 = (1 + rand(9))
		"#{numeric1}#{numeric2}"
	end

end
