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

class AccountsController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :create ]

  def index
    @year = Year.from_params(params)
    @user = User.find(session[:user_id])
    @user.refresh(session)
    @accounts = @user.current_accounts.sort_by { |a| [a.account_type_id, a.name] }
    @watchlist = @user.watchlist_accounts

    respond_to do |format|
        format.html
        format.json {
            accounts = for_sproutcore(@accounts)
            render :json => { :content => accounts }
        }
        format.xml  { render :xml => @accounts }
    end
  end

  def show
    @year = Year.from_params(params)
    session[:year_id] = @year
    @account = Account.find(params[:id])
    @account.refresh(session)
    # get updated balance if changed; @account.balance is stale?
    # TODO - why if same Object?; bug in refresh?
    @account = Account.find(params[:id])

    if @year && @year != Date.today.year
      ab = @account.account_balances.find_last_by_year(@year)
      if ab.nil?
        @account.update_saved_balances(Date.new(@year))
        ab = @account.account_balances.find_last_by_year(@year)
      end
      if !ab.nil?
        @account.cash_balance = ab.cash_balance
        @account.balance = ab.balance
      end
    end

    current_user = @account.user
    @categories = current_user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
    if (@account.investment?)
      @trade = Trade.new
      @trade_types = TradeType.find(:all)
      @cash_flow = CashFlow.new
      @securities = @account.securities
    else
      @cash_flow = @account.cash_flows.new
    end
    @cash_flow_types = CashFlowType.find(:all)
    @category_types = CategoryType.find(:all)

    respond_to do |format|
        format.html
    end
  end

  def new
    @year = Year.from_params(params)
    session[:year_id] = @year
    @account = Account.new
    @account_types = AccountType.find(:all)
    @currency_types = CurrencyType.find(:all)
  end

  def create
    @year = session[:year_id]
    current_user = User.find(session[:user_id])
    @account = current_user.accounts.new(Account.sanitize_params(params[:account]))
    if @account.save
      redirect_to @account
    else
      @account_types = AccountType.find(:all)
      @currency_types = CurrencyType.find(:all)
      render :action => 'new'
    end
  end

  def edit
    @year = Year.from_params(params)
    session[:year_id] = @year
    @account = Account.find(params[:id])
    @account_types = AccountType.find(:all)
    @currency_types = CurrencyType.find(:all)
  end

  def update
    @year = session[:year_id]
    @account = Account.find(params[:id])
    if @account.update_attributes(Account.sanitize_params(params[:account]))
      redirect_to @account
    else
      @account_types = AccountType.find(:all)
      @currency_types = CurrencyType.find(:all)
      render :action => "edit"
    end
  end

  def destroy
    @year = session[:year_id]
    @account = Account.find(params[:id])
    @user = @account.user
    @accounts = @user.accounts
    @account.purge
    render :action => "index"
  end

  def watchlist
    @user = User.find(session[:user_id])
    @watchlist = @user.watchlist_accounts
  end

  def refresh
    user = User.find(session[:user_id])
    user.refresh(session, true)
    redirect_to accounts_path
  end
end
