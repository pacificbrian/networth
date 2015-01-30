# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  skip_before_filter :test_current_user, except: [:destroy]

  def index
    redirect_to new_session_path
  end

  def new
    @session = Session.new
  end

  def create
    #logout_keeping_session!
    clear_current_user
    cred = params[:session]
    user = User.authenticate(cred[:login], cred[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      #self.current_user = user
      set_current_user(user)
      new_cookie_flag = (cred[:remember_me] == "1")
      #handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin(cred)
      @session = Session.new
      @session.login = cred[:login]
      @remember_me = cred[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    #logout_killing_session!
    clear_current_user
    flash[:notice] = "You have been logged out."
    @session = Session.new
    render :action => 'new'
  end

protected
  # Track failed login attempts
  def note_failed_signin(cred)
    flash[:notice] = "Couldn't log you in as '#{cred[:login]}'"
    logger.warn "Failed login for '#{cred[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
