# == Schema Information
# Schema version: 20101206175716
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  contact_id :integer(4)
#  keyword_id :integer(4)
#

class Subscription < ActiveRecord::Base
	belongs_to :contact
	belongs_to :keyword
end
