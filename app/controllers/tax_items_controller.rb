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

class TaxItemsController < ApplicationController
  before_filter :set_current_user

  def show
    current_user = User.find(session[:user_id])
    @year = params[:year_id]
    @account = Account.from_params(params)
    @payee = Payee.from_params(params)
    @tax_item = TaxItem.find(params[:id])
    @tax_item_cash_flows = @tax_item.cash_flows_by_year(@year, @account, @payee, true)
  end
end
