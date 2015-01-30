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

class SecurityAlertsController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :new ]

  def index
    current_user = get_current_user
    @alerts = current_user.security_alerts
  end

  def new
    if params[:security_id]
      security = Security.find(params[:security_id])
      authenticate_user(@security.account.user_id) or return
      @alert = security.security_alerts.new
    else
      @alert = SecurityAlert.new
    end
  end

  def create
    @alert = SecurityAlert.new(params[:security_alert])
    authenticate_user((@alert.security.account.user_id if @alert.security)) or return
    if @alert.save
      respond_to do |format|
        format.html { redirect_to security_alerts_path }
        format.js
      end
    else
      render :action => "new"
    end
  end

  def edit
    @alert = SecurityAlert.find(params[:id])
    authenticate_user(@alert.security.account.user_id) or return
  end

  def update
    @alert = SecurityAlert.find(params[:id])
    authenticate_user(@alert.security.account.user_id) or return
    if @alert.update_attributes(params[:alert])
      redirect_to security_alerts_path
    else
      render :action => "index"
    end
  end

  def destroy
    @alert = SecurityAlert.find(params[:id])
    authenticate_user(@alert.security.account.user_id) or return
    @alert.destroy
    redirect_to security_alerts_path
  end
end
