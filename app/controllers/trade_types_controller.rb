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

class TradeTypesController < ApplicationController
  before_filter :set_current_user, :only => [ :show ]

  def show
    current_user = get_current_user
    trade_type_id = params[:id]
    @trade_type = TradeType.find(trade_type_id)
    @year = params[:year_id]
    @account = Account.from_params(params)
    if @year
      if @account
        authenticate_user(@account.user_id) or return
        @trades = @account.ordered_trades(@year, trade_type_id)
      else
        @trades = current_user.ordered_trades(@year, trade_type_id)
      end
    else
      if @account
        authenticate_user(@account.user_id) or return
        @trades = @account.ordered_trades(nil, trade_type_id)
      else
        @trades = []
      end
    end
  end
end
