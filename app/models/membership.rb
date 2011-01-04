# == Schema Information
# Schema version: 20101206175716
#
# Table name: memberships
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  contact_id :integer(4)
#  group_id   :integer(4)
#

class Membership < ActiveRecord::Base
  belongs_to :contact
  belongs_to :group
end
