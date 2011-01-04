# == Schema Information
# Schema version: 20101206175716
#
# Table name: groups
#
#  id          :integer(4)      not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :string(255)
#  enabled     :boolean(1)
#

class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :contacts, :through => :memberships

	validates_uniqueness_of :name
end
