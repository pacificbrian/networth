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

class GainsController < ApplicationController
  before_filter :set_current_user, :only => [ :index ]

  def index
    current_user = get_current_user
    @year = params[:year_id]
    @account = Account.from_params(params)
    @gains = current_user.ordered_gains(@year, nil, @account)
    #@taxable_gain = current_user.taxable_gain_by_year(@year)
    @gain = 0
    @taxable_gain = 0
  end

  def show
    @year = params[:year_id]
    @account = Account.from_params(params)
    @trade = Trade.find_by_id(params[:id])
    @trades = Array.new
    if @trade
      authenticate_user(@trade.account.user_id) or return
      @gains = @trade.trade_gains
      @trades = Array(@trade) + @gains.map {|g| Trade.find(g.buy_id)}
    end
  end

  def update
    @year = params[:year_id]
    @account = Account.from_params(params)
    @trade = Trade.find_by_id(params[:id])
    @trades = Array.new
    if @trade
      authenticate_user(@trade.account.user_id) or return
      @trade.security.update_trade(@trade, @trade, true) 
      @trade = Trade.find_by_id(params[:id])
      gains = @trade.trade_gains
      @trades = Array(@trade) + gains.map {|g| Trade.find(g.buy_id)}
    end
    render :action => "show"
  end
end
