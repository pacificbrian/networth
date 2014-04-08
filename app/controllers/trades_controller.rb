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

class TradesController < ApplicationController
  before_filter :set_current_user, :only => [ :create ]

  def index
    @year = params[:year_id]
    if params[:account_id]
      @account = Account.find(params[:account_id])
      #@trades = @account.ordered_trades
      @trades = @account.ordered_trades.sort_by { |t| -t.id }
    else
      user = User.find(session[:user_id])
      @account = nil
      #@trades = user.ordered_trades
      @trades = user.ordered_trades.sort_by { |t| -t.id }
    end
    if @year
      @trades.delete_if { |t| t.date.year.to_i != @year.to_i }
    end
  end

  def create
    @year = session[:year_id]
    if params[:account_id]
      symbol = params[:trade][:symbol]
      @account = Account.find(params[:account_id])
      @security = @account.find_security_by_symbol(symbol)
    # TEMP, move to partial :locals
    # TODO: for in_place_edit
    #@user = User.find(session[:user_id])
    #@categories = @user.all_categories
      source = @account
      source_js = "create_securities.rjs"
    elsif params[:security_id]
      @security = Security.find(params[:security_id])
      @account = @security.account
      source = @security
      source_js = "create_trades.rjs"
    end

    @trade = @security.trades.new(Trade.sanitize_params(params[:trade]))
    @trade.account_id = @account.id

    if @trade.save
      @security.add_trade(@trade)
      # can't use @account because stale?, would need to merge into above?
      #@security.account.add_trade_cash_flows(@trade)
      #@cash_balance = @security.account.cash_balance
      @account = @security.account
      @account.add_trade_cash_flows(@trade)
      respond_to do |format|
        format.html { redirect_to source }
        format.js { render :action => source_js }
      end
    else
      redirect_to source
      #render :controller => 'accounts', :action => 'show'
      #render :controller => 'accounts', :action => 'show', :id => @account
    end
  end

  def edit
    @trade = Trade.find(params[:id])
    @account = @trade.account
    @security = @trade.security
    @trade_types = TradeType.find(:all)
  end

  def update
    @trade = Trade.find(params[:id])
    old_trade = @trade.dup # clone is wrong here!
    if @trade.update_attributes(Trade.sanitize_params(params[:trade]))
      @trade.security.update_trade(old_trade, @trade)
      redirect_to @trade.security
    else
      @trade_types = TradeType.find(:all)
      render :action => "edit"
    end
  end

  def destroy
    @trade = Trade.find(params[:id])
    @security = @trade.security
    @security.sub_trade(@trade)
    @trade.destroy
    redirect_to @security
  end
end
