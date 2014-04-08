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

class SecuritiesController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :all, :show ]

  def show
    @security = Security.find(params[:id])
    @security.update_value
    @trade = Trade.new
    @trade_types = TradeType.find(:all)

    respond_to do |format|
        format.html
    end
  end

  def index
    current_user = User.find(session[:user_id])
    securities = current_user.update_security_values
    @securities = securities.sort_by { |s| [s.account_id, s.get_name] }
  end

  def all
    current_user = User.find(session[:user_id])
    current_user.update_security_values
    securities = current_user.securities.find(:all)
    @securities = securities.sort_by { |s| [s.account_id, s.get_class, s.get_name] }
  end

  def edit
    @security = Security.find(params[:id])
    @security.symbol = @security.company.symbol
    @security.name = @security.company.name
    @security_types = SecurityType.find(:all)
    @security_basis_types = SecurityBasisType.find(:all)
  end

  def update
    @security = Security.find(params[:id])
    @security.company.update_attributes(params[:security])
    @security.update_attributes(params[:security])
    @securities = @security.account.user.active_securities
    render :action => "index"
    # or :action => "show"
  end

  def destroy
    @security = Security.find(params[:id])
    @account = @security.account
    #@security.destroy
    redirect_to @account
  end
end
