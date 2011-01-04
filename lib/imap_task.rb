#!/usr/bin/env ruby

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
puts Dir.pwd
SLEEP_TIME = 5

#imap_log = File.new("imap.log", "w")
loop {
	imap = Net::IMAP.new(LOCAL[RAILS_ENV]['server'],
		LOCAL[RAILS_ENV]['port'],
		LOCAL[RAILS_ENV]['ssl'])
	imap.authenticate('PLAIN', LOCAL[RAILS_ENV]['username'],
		LOCAL[RAILS_ENV]['password'])
  # "imap.examine('INBOX')" for read-only access
	imap.select('INBOX')
  #p imap.responses["EXISTS"][-1]
	imap.search(["NOT", "SEEN"]).each do |message|
		e = imap.fetch(message, "ENVELOPE")[0].attr["ENVELOPE"]
		puts e
		puts e.from[0].mailbox
		p e.from[0].host
		p e.to[0].mailbox
		p e.to[0].host
		p e.subject
		Message.create(:uid => e.message_id,
			:sender => "#{e.from[0].mailbox}@#{e.from[0].host}",
			#:recipients_direct => "#{e.to[0].mailbox}@#{e.to[0].host}",
			#:recipients_indirect => "#{e.cc[0].mailbox}@#{e.cc[0].host}",
			:recipients_direct => 'everybody',
			:stamp => DateTime.parse(e.date), :subject => e.subject,
			:body => imap.fetch(message, "BODY[TEXT]")[0].attr["BODY[TEXT]"],
			:keywords => 'Everything')
		#imap_log.flush
    #imap.store(message, "+FLAGS", [:Seen])
		#message.delete
	end
	#imap_log.flush
	imap.disconnect
	sleep(SLEEP_TIME)
}
imap_log.close
