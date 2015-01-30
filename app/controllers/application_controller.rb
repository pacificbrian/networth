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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :test_current_user
  before_filter :set_return_to, :only => [ :index, :show ]

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  helper :all # include all helpers, all the time

  protected

  def test_model_lookup
    #logger.warn "Controller model is: "
    #put params
  end

  def redirect_back_or_default(default='/')
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_back
    redirect_back_or_default(nil)
  end

  def set_return_to
    session[:return_to] = request.url
  end

  def sum_amount(a)
    sum = 0
    a.each {|v| sum += v.amount }
    return sum
  end   

  def update_security_values(user)
    user.securities.each do |s|
      s.update_value
    end
    session[:security_values_updated] = true
  end

  def clear_current_user
    session[:user_id] = nil
    @session_user = nil
  end

  def get_current_user
    @session_user ||= User.find_by_id(session[:user_id])
  end

  # Set current_user if unset or allow specified user to override current
  def set_current_user(new_user=nil)
    if session[:user_id].nil? or new_user
      if new_user.nil?
         uid = GlobalSettings.value_by_name("DefaultUser")
         if uid
           new_user = User.find(uid.to_i)
         end
      end
      session[:user_id] = new_user.id if new_user
      session[:security_values_updated] = false
      @session_user = User.find_by_id(new_user.id) if new_user
      @session_user.new_session(session) if @session_user
    end
    @session_user ||= User.find_by_id(session[:user_id])
  end

  def test_current_user
    @session_user ||= User.find_by_id(session[:user_id])
    unless @session_user
      set_return_to
      redirect_to login_path
    end
    @session_user
  end

  def test_sysadmin_user
    if session[:user_id] != 1
      set_return_to
      redirect_to login_path
      return false
    end
    return true
  end

  def authenticate_user(user_id)
    user = User.authenticate_current_user(session, user_id) if user_id
    if user.nil?
      redirect_back_or_default('/')
    end
    return user
  end

  def for_sproutcore(objs)
    return objs.map {|o| o[:guid] = o.id; o }
  end
end
