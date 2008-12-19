# == Schema Information
# Schema version: 20181126085723
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  firstname                 :string(255)
#  lastname                  :string(255)
#  email                     :string(255)
#  address                   :string(500)
#  company                   :string(255)
#  phone                     :string(255)
#  mobile                    :string(255)
#  activity                  :string(255)
#  nationality               :string(255)
#  edito                     :text
#  image_path                :string(500)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  activation_code           :string(40)
#  activated_at              :datetime
#  password_reset_code       :string(40)
#  system_role_id            :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#

require 'digest/sha1'
require 'regexps'
require 'country_select'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  acts_as_authorized_user
  acts_as_authorizable	

  has_many :users_workspaces, :dependent => :delete_all
  has_many :workspaces, :through => :users_workspaces

	ITEMS_LIST.each do |item|
		has_many item.pluralize.to_sym
	end

  has_many :rattings
  has_many :comments

  has_many :feed_items, :through => :feed_sources, :order => "last_updated"
  belongs_to :system_role
  
  file_column :image_path, :magick => {:size => "200x200>"}

  validates_presence_of     :login
  validates_length_of       :login,     :within => 3..40
  validates_uniqueness_of   :login,     :case_sensitive => false
  validates_format_of       :login,     :with => /\A[a-z_-]+\z/,
                                        :message => 'invalide : ne peut comporter que des lettres minuscules.'

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK

	validates_presence_of     :password
	validates_presence_of     :password_confirmation
	validates_confirmation_of :password

  validates_presence_of     :firstname, 
                            :lastname,
                            :address,
                            :company,
                            :phone,
                            :mobile,
                            :activity

  validates_format_of       :firstname, 
			                      :lastname,
														:company,
														:with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL})+\Z/
			  
  validates_format_of       :address, :with => /\A(#{ALPHA_AND_EXTENDED}|#{SPECIAL}|#{NUM})+\Z/
  
  validates_format_of       :phone, 
                  			    :mobile,
														:with => /\A(#{NUM}){10}\Z/
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :firstname, :lastname, :address, :company, :phone, :mobile, :activity, :edito, :image_path_temp, :image_path

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  
  named_scope :latest,
    :order => 'created_at DESC',
    :limit => 5
  
  def items
		@items = []
		ITEMS_LIST.map{ |item| item.pluralize }.each do |item|
			@items + self.send(item)
		end
		@items.sort { |a, b| a.created_at <=> b.created_at }
  end
  
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
    
  def has_role? role
    return (self.system_role && self.system_role.name.downcase == role.downcase)
  end
  
  def is_admin?
    has_role?('admin') or has_role?('superadmin')
  end
	
	def is_superadmin?
    has_role?('superadmin')
  end
  
  def accepts_role? role, user
    begin
      auth_method = "accepts_#{role.downcase}?"
      return (send(auth_method, user)) if defined?(auth_method)
      raise("Auth method not defined")
    rescue Exception => e
      p(e)
      puts e.backtrace[0..20].join("\n")
      raise
    end
  end
  
  def accepts_deletion? user
    return true if user.is_admin?
    false
  end
  
  def accepts_edition? user
    return true if user.is_admin?
    return true if user == self
    false
  end
  
  def accepts_creation? user
    return true if user.is_admin?
    false
  end
	 
	def full_name
		return self.lastname+" "+self.firstname
  end

	# Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

	def create_reset_code
    @reset = true
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end
  
  def recently_reset?
    @reset
  end
 
  def delete_reset_code
    self.password_reset_code = nil
    save(false)
  end
	
end
