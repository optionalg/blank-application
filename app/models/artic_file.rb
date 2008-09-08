class ArticFile < ActiveRecord::Base
  acts_as_item
  	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path,
		:user

  def self.label
    "Fichier"
  end
end
