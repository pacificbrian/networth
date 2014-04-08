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
    @accounts = @user.current_accounts.sort_by { |a| [a.account_type_id, a.id] }
    @watchlist = @user.watchlist_accounts

    respond_to do |format|
        format.json {
            accounts = for_sproutcore(@accounts)
            render :json => { :content => accounts }
        }
        format.html
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

  def to_json
    days = nil
    dates = Array.new
    end_date = Date.today

    if params[:days]
      days = params[:days].to_i
      if days.zero?
        days = nil
      end
    end

    unless days
      start_date = Date.new(end_date.year)
      days = 1 + (end_date - start_date).to_i
    end

    aid = params[:id]
    if aid
      account = Account.find(aid)
      name = account.name
      values = account.by_date_range(end_date, days, nil)
      #values = account.by_date_range(end_date, days, :normalize=>true)
    else
      current_user = User.find(session[:user_id])
      values = current_user.by_date_range(end_date, days, nil)
      #values = current_user.by_date_range(end_date, days, :normalize=>true)
    end

    vmin = vmax = nil
    0.upto(days - 1) do |d|
      date = end_date - d

      value = values[d]
      if value.nil?
        break
      end

      if (vmin.nil?)
        vmin = vmax = value
      end

      if value < vmin
        vmin = value
      end
      if value > vmax
        vmax = value
      end

      if days > 365
        dates.insert(0, date.strftime("%y %b %d"))
      else
        dates.insert(0, date.strftime("%b %d"))
      end
    end

    vrange = vmax - vmin
    vmax = vmax + (vrange * 0.05)
    vmin = vmin - (vrange * 0.05)

    #vmax = (vmax * 10).round / 10
    #vmin = (vmin * 10).round / 10

    return Chart.dateline(name, dates, values, vmin, vmax)
  end

  def json
    chart_json = to_json
    render :json => chart_json.render
  end

  def chart
    if params[:id]
      @account = Account.find(params[:id])
    end

    if params[:days]
      json_url = "json?days="+ params[:days]
    else
      json_url = "json"
    end

    @graph = open_flash_chart_object(720, 400, json_url)
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
