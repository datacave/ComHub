# == Schema Information
# Schema version: 20101206175716
#
# Table name: schedules
#
#  id             :integer(4)      not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  contact_id     :integer(10)
#  time_window_id :integer(10)
#

class Schedule < ActiveRecord::Base
  belongs_to :contact
  belongs_to :time_window
end
