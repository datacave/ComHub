# == Schema Information
# Schema version: 20101206175716
#
# Table name: keywords
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  designation :string(255)
#  lft         :integer(4)
#  rgt         :integer(4)
#  parent_id   :integer(4)
#

class Keyword < ActiveRecord::Base
	has_many :subscriptions
	has_many :contacts, :through => :subscriptions
	#acts_as_tree :order => "designation"
	acts_as_nested_set
	
	def self.includes?(keyword)
		return Keyword.find_by_designation(keyword)
	end
	
end

