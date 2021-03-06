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

class CashFlowsController < ApplicationController
  def create
    @year = session[:year_id]
    cf_params = params[:cash_flow]
    cf = CashFlow.params_to_cf(cf_params)
    @cash_flow = CashFlow.new()
    @cash_flow.account_id = cf_params[:account_id]
    @account = @cash_flow.account
    authenticate_user((@account.user_id if @account)) or return
    @categories = @account.user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}

    if cf and @cash_flow.update_from(cf)
      respond_to do |format|
        format.html { redirect_to @account }
        format.js
      end
    else
      # TODO - catch validate errors
      redirect_to @account
    end
  end

  def new
    @year = Year.from_params(params)
    session[:year_id] = @year
    @cash_flow = CashFlow.new()
    # will be nil if not from account/#/cash_flow
    @cash_flow.account_id = params[:account_id]
    @cash_flow_types = CashFlowType.find(:all)
    current_user = get_current_user
    @accounts = current_user.accounts
    @categories = current_user.all_categories
  end

  def edit
    @year = Year.from_params(params)
    session[:year_id] = @year
    @cash_flow = CashFlow.fetch(params[:id])
    authenticate_user(@cash_flow.account.user_id) or return
    @split_cash_flows = @cash_flow.get_split_cash_flows
    @split_cash_flow = SplitCashFlow.new()
    @split_cash_flow.split_from = @cash_flow.id
    @split_cash_flow.split = true
    @split_cash_flow.account_id = @cash_flow.account_id
    @split_cash_flow.date = @cash_flow.date

    @cash_flow_types = CashFlowType.find(:all)
    @categories = @cash_flow.account.user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
  end

  def in_place_edit
    edit_hash = params[:in_place_edit]

    user_cf = CashFlow.fetch(params[:id])
    authenticate_user(user_cf.account.user_id) or return
    user_cf.params_to_cf(edit_hash)

    edit_cash_flow = CashFlow.find(params[:id])
    # XXX is amount negated if update fails?
    # (why not using sub_cash_flow?
    # XXX what about !cf.split in sub_cash_flow?
    edit_cash_flow.account.adjust_cash(-edit_cash_flow.amount)
    edit_cash_flow.update_from(user_cf)

    render :text => edit_cash_flow.attributes[edit_hash.keys.first].to_s
  end

  def update
    @year = session[:year_id]
    @cash_flow = CashFlow.find(params[:id])
    @account = @cash_flow.account
    authenticate_user(@account.user_id) or return
    in_params = params[:cash_flow]
    no_edit = false

    if in_params.size == 1
      # in-place update
      cf = CashFlow.fetch(params[:id])
      cf.params_to_cf(in_params)
      k = in_params.keys[0]
      if @cash_flow.attributes[k].to_s == in_params[k].to_s
        no_edit = true
      end
    else
      cf = CashFlow.params_to_cf(in_params)
    end

    @cash_flow.account.adjust_cash(-@cash_flow.amount)
    # TODO - missing normalized balance action?
    respond_to do |format|
      if (not no_edit) and @cash_flow.update_from(cf)
        format.html { redirect_to @cash_flow.account }
        format.json { head :ok }
        format.js
      else
        format.html {
          @cash_flow_types = CashFlowType.find(:all)
          @categories = @cash_flow.account.user.all_categories
          @inplace_categories = @categories.map {|c| [c.id, c.name]}
	  render :action => "edit" 
	}
        format.json { respond_with_bip(@cash_flow) }
      end
    end
  end

  def destroy
    @year = session[:year_id]
    @cash_flow = CashFlow.find(params[:id])
    @account = @cash_flow.account
    authenticate_user(@account.user_id) or return
    @cash_flow.remove_from_account
    redirect_to @account
  end
end
