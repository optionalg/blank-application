# == Schema Information
# Schema version: 20181126085723
#
# Table name: publications
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  feed_source_id :integer(4)
#  title          :string(255)
#  description    :text
#  state          :string(255)
#  link           :string(255)
#  content        :string(255)
#  authors        :string(255)
#  date_published :datetime
#  last_updated   :datetime
#  copyright      :string(255)
#  categories     :string(255)
#  file_path      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  tags           :string(255)
#

class Publication < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :author, :file_path]
  
  file_column :file_path
  
end
