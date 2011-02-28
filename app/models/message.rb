# == Schema Information
# Schema version: 20101206175716
#
# Table name: messages
#
#  id                  :integer(4)      not null, primary key
#  created_at          :datetime
#  updated_at          :datetime
#  uid                 :string(255)
#  sender              :string(255)
#  recipients_direct   :string(255)
#  recipients_indirect :string(255)
#  stamp               :datetime
#  subject             :string(255)
#  body                :text
#  importance          :integer(4)
#  keywords            :text
#  state               :string(255)     default("received")
#

class Message < ActiveRecord::Base

	has_many :notifications, :dependent => :destroy
  has_many :channels, :through => :notifications

	# This is a good idea, but we don't assign this on creation, only on
	# return from Twilio. NULL's count against us in this check.
  #validates_uniqueness_of :uid

	acts_as_state_machine :initial => :received

	state :received
	state :throttled
	state :suppressed
	state :addressed
	state :apportioned

	event :throttle do
		transitions :to => :throttled, :from => :received
	end

	event :suppress do
		transitions :to => :suppressed, :from => [:received, :apportioned]
	end

	event :address do
		transitions :to => :addressed, :from => :received
	end

	event :apportion do
		transitions :to => :apportioned, :from => :addressed
	end

	states.each { |s| named_scope s, :conditions => { :state => s.to_s } }

  LEVELS = %w{NORMAL CRITICAL INFORMATIONAL MAJOR MINOR}

  after_create :process

	def process

		# Message throttle
		unless body.match(/^RECOVERY/)
			m = Message.find(:all, :order => "created_at DESC", :limit => 3)[2]
			m ? t = m.created_at : t = Time.now - 1.day
			freshness = Time.now - t
			if freshness < 30 # seconds
        # FIXME: Explanation of the order of events?...
        self.throttle! unless body.match(/throttled!$/)
        # Don't send another message about throttling for 30 minutes
        m = Message.find(:last, :conditions =>
          "subject = 'Messages are being throttled!' AND
          created_at >= '#{(DateTime.now - 30.seconds).to_s(:db)}'")
        if m.nil?
          Message.create(
            :sender => "comhub@data-cave.com",
            :body => "Messages are being throttled!",
            :subject => "There may be more problems coming in than are being reported!",
            :recipients_direct => recipients_direct,
            :stamp => DateTime.now,
            :keywords => keywords
          )
        end
        #message = "Messages are being throttled."
				#Message.admin_override(message)
			end
		end
	
		unless self.is_being_suppressed? || self.throttled? || recipients_direct.nil?
		
			contacts = []
			addresses = recipients_direct.split(/, ?/) #| self.recipients_indirect.split(/, ?/)
			addresses.each do |address|
				if address.match(/@/) || address.match(/\d\d\d-?\d\d\d-?\d\d\d\d/)
					contact = Contact.find(:first, :include => :channels,
						:conditions => [ "channels.address = ?", address ])
				else
					contact = Contact.find_by_username(address)
				end
				unless contact.nil?
					contacts << contact
				else # must be a group
					group = Group.find_by_name(address)
					unless group.nil?
						contacts << group.contacts
						contacts.flatten!
					end
				end
			end
			
			unless contacts.empty?
				contacts.uniq!
				self.address!
				begin
					Notification.apportion(self, contacts)
					self.apportion!
				rescue Exception => e
					logger.error(e.to_yaml)
				ensure
					# Check if notifications have not come to rest at the "delivered" state.
					if notifications.count == 0 && self.important?
						Message.admin_override("ALERT! Message #{id} did not generate any notifications!")
					else
						failures = notifications.select { |n| n.state != 'delivered' }
						if failures.count > 0
							# Should probably create a real message and force it to ignore the normal rules.
							message = "Notifications for message #{id} did not go through!"
							logger.error("Message was: #{message}")
							Message.admin_override(message)
						end
					end
				end
			end

		end

  end

	def is_being_suppressed?
		unless body.nil?
			lines = body.split("\n")
			n = Notification.find(:first,
				:conditions => "created_at BETWEEN DATE_SUB(UTC_TIMESTAMP(), interval 30 MINUTE) " +
				"AND UTC_TIMESTAMP() AND body LIKE '#{lines[0].gsub(/'/, "''")}%' AND " +
        "state = 'acknowledged'")
			unless n.nil?
				self.suppress!
				return true
			end
		end
		false
	end

	def self.admin_override(text)
		system("echo \"#{text}\" | mail #{LOCAL['admin_pager']}")
	end

  def important?
    if !importance.nil? && !importance.empty?
      if importance.downcase == "informational"
        false
      else
        true
      end
    else
      true
    end
  end
end
