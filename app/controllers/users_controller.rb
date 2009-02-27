class UsersController < ApplicationController
	
  acts_as_ajax_validation

	layout "application", :except => [:forgot_password, :reset_password]

  make_resourceful do
    actions :all

    before :destroy do
      no_permission_redirection unless @current_object.accepts_destroy_for?(@current_user)
    end

    before :edit, :update do
      no_permission_redirection unless @current_object.accepts_edit_for?(@current_user)
    end


    before :new, :create do
      no_permission_redirection unless @current_object.accepts_new_for?(@current_user)
    end

    before :show do
			no_permission_redirection unless @current_object.accepts_show_for?(@current_user)
      @is_admin = @current_object.is_admin?
      @moderated_ws =
        Workspace.with_moderator_role_for(@current_object) |
        Workspace.administrated_by(@current_object)
      @writter_role_on_ws = Workspace.with_writter_role_for(@current_object)
      @reader_role_on_ws = Workspace.with_reader_role_for(@current_object)
    end

		before :index do
			no_permission_redirection unless @current_objects.first.accepts_index_for?(@current_user)
			@current_objects = current_objects.paginate(
					:page => params[:page],
					:order => :title,
					:per_page => 20
			)
    end

		after :create do
			# Creation of the private workspace for the user
			ws = Workspace.create(:title => "Private space of #{@current_object.login}", :creator_id => @current_object.id, :state => 'private')
			# To assign the 'ws_admin' role to the user in his privte workspace
			UserWorkspace.create(:user_id => @current_object.id, :worskpace_id => ws.id, :role_id => Role.find_by_name('ws_admin'))
			flash[:notice] = I18n.t('user.new.flash_notice')
		end

		after :create_fails do
			flash[:error] = I18n.t('user.new.flash_error')
    end

    after :update do
			flash[:notice] = I18n.t('user.edit.flash_notice')
    end

    after :update_fails do
			flash[:error] = I18n.t('user.edit.flash_error')
    end

  end
 
  def current_objects
     conditions = if params['login']
       ["login LIKE :login OR firstname LIKE :login OR lastname LIKE :login",
         { :login => "%#{params['login']}%"}]
     else
       {}
     end
     @current_objects ||= current_model.find(:all, :conditions => conditions)
   end
	
	# Function allowing to activate the user with the RESTful authentification plugin
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Subscription complete !"
    end
    redirect_back_or_default('/')
  end

	# Function allowing to gain his password by email in case of forgot
  def forgot_password    
		return unless request.post?
		if @user = User.find_by_email(params[:user][:email])
		  @user.create_reset_code
		  flash.now[:notice_forgot] = I18n.t('user.forgot_password.flash_notice')
			render :action => "forgot_password"
		else
		  flash.now[:error_forgot] = I18n.t('user.forgot_password.flash_error')
			render :action => "forgot_password"
		end
  end
 
  # Function allowing to reset the password of the current user after to have received a reset link in an email
  def reset_password
    if (@user = User.find_by_password_reset_code(params[:password_reset_code]) unless params[:password_reset_code].nil?)
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "#{@user.login},"+I18n.t('user.reset_password.flash_notice')
        redirect_to "/login"
      else
				flash[:error] = I18n.t('user.reset_password.flash_error')
        render :action => :reset_password
      end
		end
    else
			flash[:error] = I18n.t('user.reset_password.flash_error_link')
			redirect_to "/login"
		end
  end  

	# permit 'administration of user'
	def administration
		@current_object = current_user
		@workspace = Workspace.new
		@workspaces = if (current_user.system_role == "Admin")
		  Workspace.find(:all)
	  else
	    Workspace.administrated_by(current_user) + Workspace.moderated_by(current_user)
    end
  end
 
end
