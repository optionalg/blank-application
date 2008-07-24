class Permission < ActiveRecord::Base
	
	has_many :permissions_roles
	has_many :roles, :through => :permissions_roles
	
	validates_presence_of :name
	
end
