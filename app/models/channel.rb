# == Schema Information
# Schema version: 20101206175716
#
# Table name: channels
#
#  id             :integer(4)      not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  mechanism_id   :integer(4)
#  contact_id     :integer(4)
#  address        :string(255)
#  enabled        :boolean(1)
#  time_window_id :integer(4)
#

class Channel < ActiveRecord::Base
  belongs_to :contact
  belongs_to :mechanism
	has_many :notifications
	belongs_to :time_window

  validates_uniqueness_of :address, :scope => :mechanism_id
	validates_format_of :address, :with => /@/i,
		:if => :address_is_email?
	validates_format_of :address, :with => /\d\d\d\d\d\d\d\d\d\d/,
		:if => :address_is_phone?

	named_scope :active, :conditions => { :enabled => true }
	
	def before_validation
		self.address = address.gsub(/[^0-9]/, "") if mechanism.designation == "sms"
	end

	def address_is_email?
		mechanism.designation == "smtp"
	end

	def address_is_phone?
		mechanism.designation == "sms"
	end

	def address_is_voice?
		mechanism.designation == "voice"
	end

	# Dual function function. This checks AND CLEARS suppression.
	def is_being_suppressed?
		return false if !suppressed?
		if DateTime.now.to_f - suppressed.to_f > 30 * 60
			self.suppressed = nil
			self.save
			return false
		end
		true
	end

	def in_play?
		return true if time_window.nil? ||
			TimeRange.new(time_window.definition).include?(Time.new)
		false
	end

end
