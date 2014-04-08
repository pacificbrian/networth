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
  # Rails2 comment:
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8ce3ba8e8765a56886e53c05db510d11'

  helper :all # include all helpers, all the time

  protected

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

  def set_current_user
    unless session[:user_id]
      user = User.find(1)
      session[:user_id] = user.id
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
