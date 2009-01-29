# == Schema Information
# Schema version: 20181126085723
#
# Table name: taggings
#
#  id            :integer(4)      not null, primary key
#  tag_id        :integer(4)
#  user_id       :integer(4)
#  taggable_id   :integer(4)
#  taggable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
end
