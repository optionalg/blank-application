class UsersWorkspace < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :workspace
	belongs_to :role
	
	validates_uniqueness_of :user_id, :scope => :workspace_id
end
