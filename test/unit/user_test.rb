require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  def test_quentin_valid?
    # This fixture will be used as a valid record for testing
    assert users(:quentin).valid?
  end
  
  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'monkey')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  # Our tests
  
  def test_firstname_should_not_validate
    assert_invalid_format :firstname, ["", "dddd@ðððð", "1234"]
  end
  
  def test_lastname_should_not_validate
    assert_invalid_format :lastname, ["", "jdk@k", "1234"]
  end
  
  def test_email_should_not_validate
    assert_invalid_format :email, ["", "jdk@k", "jdk@ffff.f"]
  end
  
  def test_address_should_not_validate
    assert_invalid_format :addr, ["", "jdk@k", "jdk@ffff.f"]
  end
  
  def test_laboratory_should_not_validate
    assert_invalid_format :laboratory, ["", "jdk@k", "1234"]
  end
  
  def test_phone_should_not_validate
    assert_invalid_format :phone, ["", "jdk@k", "1234", "11 11 11 1"]
  end
  
  def test_mobile_should_not_validate
    assert_invalid_format :mobile, ["", "jdk@k", "1234", "11 11 11 1"]
  end
  
  def test_activity_should_not_validate
    assert_invalid_format :activity, ""
  end
	
	def test_remove_element_associated_when_object_destroyed
		assert id = users(:quentin).id, "Workspace nil"
		assert UsersWorkspace.count(:all, :conditions => {:user_id => id})!=0, "No elements in the U-W join table"
		assert users(:quentin).destroy, "Cannot destroy the role"
		assert UsersWorkspace.count(:all, :conditions => {:user_id => id})==0, "UsersWorkspaces associated not removed"
	end
  
protected
  def create_user(options = {})
    record = User.new({
      :login => 'quire',
      :email => 'quire@example.com',
      :password => 'quire69',
      :password_confirmation => 'quire69',
      :firstname => 'quire',
      :lastname => 'dupond',
      :addr => '42 rue du paradis',
      :laboratory => 'myLab',
      :phone => '0112345678',
      :mobile => '0612345678',
      :activity => 'nothingAtAll',
      :edito => 'Ici mon edito' }.merge(options))
    record.save
    record
  end
end
