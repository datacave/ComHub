# == Schema Information
# Schema version: 20101206175716
#
# Table name: mechanisms
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  designation :string(255)
#

class Mechanism < ActiveRecord::Base
	has_many :channels
	has_many :notifications, :through => :channel
end
