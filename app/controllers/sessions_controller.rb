# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :is_logged?, :except => [:destroy, :change_language]
  layout 'login'

  # Login Page for New Session
  def new
  end

  # Create New Session for given Login and Passowrd
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user && user.activated_at
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = I18n.t('user.session.flash_notice')
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash[:error] = I18n.t('user.session.flash_error')
      render :action => 'new'
       
    end
  end

  # Update Last Logged In attribute and Kill User Session
  def destroy
    User.find(current_user.id).update_attributes(:last_connected_at => Time.now)
    logout_killing_session!
    flash[:notice] = "Vous avez été déconnecté"
    redirect_back_or_default('/')
  end

  # Change Language Option for Current User
	def change_language
    current_user.update_attributes(:u_language => params[:locale])
		render(:update) { |page| page.call 'location.reload' }
		#redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Impossible de vous connecter en tant que '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
