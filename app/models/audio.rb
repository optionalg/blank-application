# == Schema Information
# Schema version: 20181126085723
#
# Table name: audios
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)     default("initial")
#  audio_file_name    :string(255)
#  audio_content_type :string(255)
#  audio_file_size    :integer(4)
#  audio_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  tags               :string(255)
#  viewed_number      :integer(4)
#  rates_average      :integer(4)
#  comments_number    :integer(4)
#  category           :string(255)
#

class Audio < ActiveRecord::Base

  # Item specific Library - /lib/acts_as_item
  acts_as_item

  # Paperclip Attachment 
  has_attached_file :audio,
    :url =>  "/uploaded_files/audio/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/audio/:id/:style/:basename.:extension"

  # Paperclip Validations
  validates_attachment_presence :audio

  #validates_attachment_content_type :audio, :content_type => ['audio/wav','audio/x-wav', 'audio/mpeg', 'audio/x-ms-wma', 'video/mp4' ]

  validates_attachment_size(:audio, :less_than => 100.megabytes)

  # Media Type for the Model used in Converter Worker for Encoding.
  def media_type
    audio
  end

  # Codec used for Encoding Audio to MP3 using FFMPEG.
  def codec
    "-acodec libmp3lame -y"
  end

end
