class Publication < ActiveRecord::Base
  acts_as_item
  #acts_as_xapian :texts => [:title, :description, :author]
  
  file_column :file_path
  
  def self.label
    "Publication"
  end
end
