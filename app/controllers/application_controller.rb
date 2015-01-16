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
  before_filter :set_return_to, :only => [ :index, :show ]

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  helper :all # include all helpers, all the time

  protected

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

  # Set current_user if unset or allow specified user to override current
  def set_current_user(_set_user=nil)
    if session[:user_id].nil? or _set_user
      # TODO move DefaultUser lookup to get_current_user
      # uid = Global.find_by_name("DefaultUser")
      uid = 1
      if _set_user.nil?
        _set_user = User.find(uid)
      end
      session[:user_id] = _set_user.id
      session[:security_values_updated] = false
      #user.update_security_values
    end
    session[:user_id]
  end

  def get_current_user
    unless session[:user_id]
      session[:return_to] = request.request_uri
      redirect_to new_session_path
    end
    session[:user_id]
  end

  def for_sproutcore(objs)
    return objs.map {|o| o[:guid] = o.id; o }
  end
end
