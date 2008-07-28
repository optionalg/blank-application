class Role < ActiveRecord::Base
	
	has_many :permissions_roles, :dependent => :delete_all
	has_many :permissions, :through => :permissions_roles
	has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	has_many :workspaces, :through => :users_workspaces
	
	validates_presence_of :name
	
end
