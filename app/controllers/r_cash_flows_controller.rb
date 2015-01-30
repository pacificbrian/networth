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

class RCashFlowsController < ApplicationController
  def create
    @r_cash_flow = RCashFlow.new()

    cf_params = params[:r_cash_flow]
    cf = RCashFlow.params_to_cf(cf_params)
    @r_cash_flow.account_id = cf_params[:account_id]
    @account = @r_cash_flow.account
    authenticate_user((@account.user_id if @account))

    if cf and @r_cash_flow.update_from(cf)
      # XXX repeat_interval_type_id cleared in update_from?
      @r_cash_flow.repeat_interval_type_id = cf.repeat_interval_type_id
      @r_cash_flow.repeats_left =  cf.repeats_left
      @r_cash_flow.rate =  cf.rate
      @r_cash_flow.add_repeat_interval

      respond_to do |format|
        format.html { redirect_to @account }
        format.js
      end
    else
      redirect_to @account
    end
  end

  def index
    current_user = get_current_user
    @r_cash_flow = RCashFlow.new()
    # will be nil if not from account/#/r_cash_flow
    @r_cash_flow.account_id = params[:account_id]
    account = @r_cash_flow.account
    if account
      authenticate_user(account.user_id)
      @r_cash_flows = account.r_cash_flows
    else
      @r_cash_flows = current_user.r_cash_flows
    end
    @cash_flow_types = CashFlowType.find(:all)
    @repeat_interval_types = RepeatIntervalType.find(:all)
    @accounts = current_user.accounts
    @categories = current_user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
  end


  def new
    @r_cash_flow = RCashFlow.new()
    # will be nil if not from account/#/r_cash_flow
    @r_cash_flow.account_id = params[:account_id]
    @cash_flow_types = CashFlowType.find(:all)
    @repeat_interval_types = RepeatIntervalType.find(:all)
    current_user = get_current_user
    @accounts = current_user.accounts
    @categories = current_user.all_categories
  end

  def edit
    @r_cash_flow = RCashFlow.fetch(params[:id])
    authenticate_user(@r_cash_flow.account.user_id)
    @rpi = @r_cash_flow.repeat_interval
    if @rpi
      @r_cash_flow.repeats_left = @rpi.repeats_left
      @r_cash_flow.rate = @rpi.rate
    end
    @split_cash_flows = @r_cash_flow.get_split_cash_flows

    @r_split_cash_flow = SplitCashFlow.new()
    @r_split_cash_flow.split_from = @r_cash_flow.id
    @r_split_cash_flow.split = true
    @r_split_cash_flow.account_id = @r_cash_flow.account_id
    @r_split_cash_flow.date = @r_cash_flow.date
    @r_split_cash_flow.repeat_interval_id = @r_cash_flow.repeat_interval_id

    @cash_flow_types = CashFlowType.find(:all)
    @repeat_interval_types = RepeatIntervalType.find(:all)
    @categories = @r_cash_flow.account.user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
  end

  def update
    @r_cash_flow = RCashFlow.find(params[:id])
    authenticate_user(@r_cash_flow.account.user_id)
    in_params = params[:r_cash_flow]
    no_edit = false

    if in_params.size == 1
      # in-place update
      cf = RCashFlow.fetch(params[:id])
      cf.params_to_cf(in_params)
      k = in_params.keys[0]
      if @r_cash_flow.attributes[k].to_s == in_params[k].to_s
        no_edit = true
      end
    else
      cf = RCashFlow.params_to_cf(in_params)
    end

    respond_to do |format|
      if (not no_edit) and @r_cash_flow.update_from(cf)
	@r_cash_flow.repeat_interval_type_id = cf.repeat_interval_type_id
        @r_cash_flow.repeats_left =  cf.repeats_left
        @r_cash_flow.rate =  cf.rate
        @r_cash_flow.update_repeat_interval
        format.html { redirect_to @r_cash_flow.account }
        format.json { head :ok }
        format.js
      else
        format.html {
          @cash_flow_types = CashFlowType.find(:all)
          @categories = @r_cash_flow.account.user.all_categories
          @inplace_categories = @categories.map {|c| [c.id, c.name]}
          @repeat_interval_types = RepeatIntervalType.find(:all)
	  render :action => "edit" 
	}
        format.json { respond_with_bip(@cash_flow) }
      end
    end
  end

  def apply
    @r_cash_flow = RCashFlow.find(params[:id])
    @account = @r_cash_flow.account
    authenticate_user(@account.user_id)

    if @r_cash_flow.record_single_cash_flow
      respond_to do |format|
        format.html { redirect_to @account }
        format.js
      end
    else
      redirect_to @account
    end
  end

  def destroy
    @cash_flow = CashFlow.find(params[:id])
    @account = @cash_flow.account
    authenticate_user(@account.user_id)

    # don't know.... a rails bug seems to require this.....
    @cash_flow.split = false

    @cash_flow.purge
    redirect_to @account
  end
end
