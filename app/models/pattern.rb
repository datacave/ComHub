# == Schema Information
# Schema version: 20101206175716
#
# Table name: patterns
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  definition :string(255)
#  contact_id :integer(4)
#  active     :boolean(1)
#  duration   :string(255)
#

class Pattern < ActiveRecord::Base
	belongs_to :contact

	def in_play?
		if duration.nil?
			return active?
		else
			if updated_at + duration.to_i.hours < DateTime.now then
				update_attributes(:active => false)
				return false
			end
		end
		return true
	end

end
