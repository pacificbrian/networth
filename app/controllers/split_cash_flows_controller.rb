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

class SplitCashFlowsController < CashFlowsController
  def redirect_to_parent(cash_flow)
    if (cash_flow.repeat?)
      controller = 'r_cash_flows'
    else
      controller = 'cash_flows'
    end

    redirect_to :id => cash_flow,
                :action => 'edit',
                :controller => controller
  end

  def create
    cf_params = params[:split_cash_flow]
    split_from = cf_params[:split_from]
    cf = SplitCashFlow.params_to_cf(cf_params)
    @cash_flow = CashFlow.find(split_from)
    @split_cash_flow = SplitCashFlow.new()
    @split_cash_flow.account_id = @cash_flow.account_id
    cf and @split_cash_flow.update_from(cf)

    respond_to do |format|
      format.html { redirect_to_parent(@cash_flow) }
      format.js
    end
  end

  def update
    @year = session[:year_id]
    @split_cash_flow = CashFlow.find(params[:id])
    @account = @split_cash_flow.account
    in_params = params[:split_cash_flow]
    no_edit = false

    if in_params.size == 1
      # in-place update
      cf = SplitCashFlow.fetch(params[:id])
      cf.params_to_cf(in_params)
      k = in_params.keys[0]
      if @split_cash_flow.attributes[k].to_s == in_params[k].to_s
        no_edit = true
      end
    else
      cf = SplitCashFlow.params_to_cf(in_params)
    end

    respond_to do |format|
      if (not no_edit) and @split_cash_flow.update_from(cf)
        format.json { head :ok }
        format.js
      else
        format.json { respond_with_bip(@split_cash_flow) }
      end
      format.html { redirect_to_parent(@split_cash_flow.cash_flow) }
    end
  end

  def destroy
    @cash_flow = CashFlow.find(params[:id])
    @account = @cash_flow.account
    @cash_flow.destroy
    redirect_to @account
  end
end
