# == Schema Information
# Schema version: 20101206175716
#
# Table name: contacts
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  username   :string(255)
#  last_name  :string(255)
#  first_name :string(255)
#  enabled    :boolean(1)
#

class Contact < ActiveRecord::Base
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :channels, :dependent => :destroy
  has_many :handlers, :through => :channels
  has_many :schedules
  has_many :time_windows, :through => :schedules
	has_many :subscriptions
	has_many :keywords, :through => :subscriptions
	has_many :patterns

	validates_presence_of :username
	validates_uniqueness_of :username
	validates_uniqueness_of :first_name, :scope => :last_name

	# I wish I could make this work for a habtm relationship...
	#accepts_nested_attributes_for :channels, :allow_destroy => true
	attr_accessible :username, :enabled, :last_name, :first_name,
		:time_window_ids, :group_ids, :keyword_ids,
		:new_channel_attributes, :existing_channel_attributes,
		:new_pattern_attributes, :existing_pattern_attributes

	after_update :save_channels, :save_patterns

  def full_name
		unless last_name.nil? || first_name.nil?
			last_name + ", " + first_name
		end
  end

  def on_call?
    on_call = false
    now = Time.new
    self.schedules.each do |schedule|
      tr = TimeRange.new(schedule.time_window.definition)
      on_call = true if tr.include?(now) && schedule.time_window.active? == true
    end
    on_call
  end

	def new_channel_attributes=(channel_attributes)
		channel_attributes.each do |attributes|
			channels.build(attributes)
		end
	end

	def existing_channel_attributes=(channel_attributes)
		channels.reject(&:new_record?).each do |channel|
		attributes = channel_attributes[channel.id.to_s]
			if attributes
				channel.attributes = attributes
			else
				channels.delete(channel)
			end
		end
	end

	def save_channels
		channels.each do |channel|
			channel.save(false)
		end
	end

	def new_pattern_attributes=(pattern_attributes)
		pattern_attributes.each do |attributes|
			patterns.build(attributes)
		end
	end

	def existing_pattern_attributes=(pattern_attributes)
		patterns.reject(&:new_record?).each do |pattern|
		attributes = pattern_attributes[pattern.id.to_s]
			if attributes
				pattern.attributes = attributes
			else
				patterns.delete(pattern)
			end
		end
	end

	def save_patterns
		patterns.each do |pattern|
			pattern.save(false)
		end
	end

	def filtering?(text)
		filtered = false
		patterns.each do |p|
			filtered = true if p.in_play? && text.match(/#{p.definition}/)
		end
		filtered
	end

	def subscribed?(text)
		if text.nil? || keywords.include?(Keyword.find_by_designation('Everything')) ||
			!(keywords.map { |k| k.designation } & text).empty?
			true
		else
			false
		end
	end

end
