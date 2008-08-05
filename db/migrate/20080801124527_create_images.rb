class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
			t.integer :user_id
      t.string :title
      t.text :description
      t.string :file_path
			t.boolean :private, :default => false
			
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
