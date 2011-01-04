# == Schema Information
# Schema version: 20101206175716
#
# Table name: time_windows
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  definition  :string(255)
#  description :string(255)
#  active      :boolean(1)
#

class TimeWindow < ActiveRecord::Base
  has_many :schedules
  has_many :contacts, :through => :schedules
	has_many :channels
end
