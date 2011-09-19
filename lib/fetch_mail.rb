#!../script/runner

# This is intended to be run as a cron job every minute to pick up
# mail from the IMAP Inbox.

require 'net/imap'
require 'yaml'

class ImapPlainAuthenticator
  def process(data)
    return "#{@user}\0#{@user}\0#{@password}"
  end

  def initialize(user, password)
    @user = user
    @password = password
  end
end

Net::IMAP::add_authenticator('PLAIN', ImapPlainAuthenticator)

#Dir.chdir("#{RAILS_ROOT}/lib")

imap = Net::IMAP.new(LOCAL[RAILS_ENV]['server'],
	LOCAL[RAILS_ENV]['port'],
	LOCAL[RAILS_ENV]['ssl'])
imap.authenticate('PLAIN', LOCAL[RAILS_ENV]['username'],
	LOCAL[RAILS_ENV]['password'])

# For read-only access, if you don't want to delete
#imap.examine('INBOX')
imap.select('INBOX')

#p imap.responses["EXISTS"][-1]
imap.search(["NOT", "SEEN"]).each do |message|
	envelope = imap.fetch(message, "ENVELOPE")[0].attr["ENVELOPE"]
	#p envelope.inspect
	from_address = envelope.from[0].mailbox
	from_host = envelope.from[0].host
	to_address = envelope.to[0].mailbox
	to_host = envelope.to[0].host
	subject = envelope.subject
	body = imap.fetch(message, "BODY[TEXT]")[0].attr["BODY[TEXT]"]
	if subject == "Alarm from Intelli-M Access"
		# The raw body of a door alarm sent from Intelli-M looks like this:
		#"\"<b>Date:</b> 3/3/2011 9:51:40 AM</br><b>User:</b> (-)</br><b>Event:</b>=\\r\\n ForcedOpen</br><b>Location:</b> Door: 106-Office_Area-NOC and Zone:\\r\\n\\r\\n\""
		if body.match(/.*ForcedOpen.*/)
			body.gsub!(/\r\n/, '')
			body.gsub!(/<\/br>/, '|')
			body.gsub!(/<\/?[^>]*>/, '')
			door = event = ""
			body.split('|').each do |line|
				door = line.split('Door: ')[1] if line.match(/^Location/)
				event = line.split('Event:= ')[1] if line.match(/^Event/)
			end
			door.gsub!(/and Zone:/, '')
			subject = "Door #{door} #{event}"
			Message.create(:uid => envelope.message_id,
				:sender => "#{from_address}@#{from_host}",
				#:recipients_direct => "#{envelope.to[0].mailbox}@#{envelope.to[0].host}",
				#:recipients_indirect => "#{envelope.cc[0].mailbox}@#{envelope.cc[0].host}",
				:recipients_direct => 'everybody',
				:stamp => DateTime.parse(envelope.date),
				:subject => subject,
				:body => subject,
				:keywords => 'Security')
			#imap.store(message, "-FLAGS", [:Seen])
		else
			Message.create(:uid => envelope.message_id,
				:sender => "#{from_address}@#{from_host}",
				#:recipients_direct => "#{envelope.to[0].mailbox}@#{envelope.to[0].host}",
				#:recipients_indirect => "#{envelope.cc[0].mailbox}@#{envelope.cc[0].host}",
				:recipients_direct => 'everybody',
				:stamp => DateTime.parse(envelope.date),
				:subject => subject,
				:body => body,
				:keywords => 'Infrastructure')
		end
	end
	imap.store(message, "+FLAGS", [:Deleted])
end

imap.close
imap.disconnect
