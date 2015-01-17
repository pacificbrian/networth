#
# Copyright © 2010-2014 Brian Welty <bkwelty@zoho.com>
#
# This file is part of Networth.
# 
# Networth is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# Networth is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem

  def new
    @user = User.new
  end
 
  def create
    send_code=false
    #logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.encrypt_save(send_code)
    if success && @user.errors.empty?
      if send_code
        flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
        redirect_to activate_user_path
      else
        @user.activate!
        flash[:notice] = "Thanks for registering!"
        redirect_to new_session_path
      end
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    #logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    when user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def lookup_user(params)
    user_id = params[:id].to_i
    current_user = User.find(session[:user_id])
    if current_user.nil? or current_user.id != user_id
      logger.warn "Attempt to lookup non-current User " + user_id.to_s + " (" + (current_user.id if current_user).to_s + ")"
      redirect_back_or_default('/')
    end
    @user = current_user
  end

  def edit
    @user = lookup_user(params)
  end

  def update
    @user = lookup_user(params)
    if @user.update_attributes(params[:user])
      redirect_to @user
    else
      render :action => "edit"
    end
  end

  def show
    user = lookup_user(params)
    redirect_to accounts_path
  end

  def refresh
    user = lookup_user(params)
    user.refresh(session, true)
    redirect_back_or_default('/')
  end
end
