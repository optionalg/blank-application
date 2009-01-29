# == Schema Information
# Schema version: 20181126085723
#
# Table name: generic_items
#
#  item_type          :string(11)      default(""), not null
#  id                 :integer(4)      default(0), not null, primary key
#  user_id            :integer(4)
#  user_name          :text(2147483647
#  title              :string(255)
#  description        :text
#  created_at         :datetime
#  updated_at         :datetime
#  number_of_comments :integer(8)
#  workspace_titles   :string(341)
#  average_rate       :decimal(14, 4)
#

class GenericItem < ActiveRecord::Base
  self.inheritance_column = :item_type

	ITEMS.each do |item|
		named_scope item.pluralize.to_sym,
			:conditions => { :item_type => item.camelize }
	end
	
  named_scope :from_workspace, lambda { |ws_id|
    raise 'WS expected' unless ws_id
    { :select => 'generic_items.*',
      :joins => 'LEFT JOIN items ON generic_items.item_type = items.itemable_type AND generic_items.id = items.itemable_id',
      :conditions => "items.workspace_id = #{ws_id}"
    }
  }
  
  named_scope :consultable_by, lambda { |user_id|
    raise 'User expected' unless user_id
    return { } if User.find(user_id).is_admin?
    { :conditions => %{
        user_id = #{user_id} OR
        ( SELECT count(*)
          FROM items, users_workspaces
          WHERE
            items.itemable_type = generic_items.item_type AND
            items.itemable_id = generic_items.id AND
            users_workspaces.workspace_id = items.workspace_id AND
            users_workspaces.user_id = #{user_id} ) > 0 }}
  }
  
  named_scope :most_commented,
    :order => 'generic_items.number_of_comments DESC',
    :limit => 5
    
  named_scope :best_rated,
    :order => 'generic_items.average_rate DESC',
    :limit => 5
   
  named_scope :latest,
    :order => 'generic_items.created_at DESC',
    :limit => 5
	
end
