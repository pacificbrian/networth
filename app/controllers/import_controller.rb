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

class ImportController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :create ]

  # TODO: move this to 'new' and create 'index' that lists Account.imports?
  def index
    @year = Year.from_params(params)
    # will be nil if not from account/#/import
    @account = Account.from_params(params)
    if @account
      authenticate_user(@account.user_id) or return
      current_user = @account.user
      @recent_imports = @account.imports
    else
      current_user = get_current_user
    end
    @accounts = current_user.accounts
  end

  def show
    @year = Year.from_params(params)
    @import = Import.find(params[:id])
    authenticate_user(@import.account.user_id) or return
    @account = @import.account
    @import_cash_flows = @import.cash_flows
    @import_trades = @import.trades
    @categories = @account.user.all_categories
    @allow_edit = true
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
  end

  def create
    @year = Year.from_params(params)
    @account = Account.find(params[:import][:account_id])
    authenticate_user((@account.user_id if @account)) or return

    if params[:commit] == "Import OFX"
      name = params[:import][:ofx_name]
      pass = params[:import][:ofx_pass]
      @import = @account.import_ofx_with_cred(name, pass)
    elsif params[:commit] == "Import CSV"
      file = params[:import][:csv_file]
      @import = @account.import_csv(file)
    elsif params[:commit] == "Import QFX"
      file = params[:import][:qfx_file]
      puts file.original_filename
      @import = @account.import_ofx_from_file(file)
    else
      file = params[:import][:qif_file]
      @import = @account.import_qif(file)
    end

    if @import
      #flash.now[:message]="Import Successful: #{n} new transactions added."
      flash.now[:message]="Import Successful."
      if @year
        redirect_to year_account_import_path(@year, @account, @import)
      else
        redirect_to account_import_path(@account, @import)
      end
    else
      flash.now[:message]="Import Failed."
      if @year
        redirect_to year_account_import_index_path(@year, @account)
      else
        redirect_to account_import_index_path(@account)
      end
    end
  end
end
