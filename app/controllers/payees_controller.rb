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

class PayeesController < ApplicationController
  before_filter :set_current_user

  def redirect_target(account)
    if account
      account_payees_path(account)
    else
      payees_path
    end
  end

  def index
    current_user = get_current_user
    @account = Account.from_params(params)
    if @account
      authenticate_user(@account.user_id) or return
      @payees = @account.payees.uniq.sort_by { |p| -p.use_count(@account) }
    else
      @payees = current_user.payees.sort_by { |p| -p.use_count }
    end
    @categories = current_user.all_categories
    @payee = Payee.new
  end

  def create
    current_user = get_current_user
    @account = Account.from_params(params)
    @payee = current_user.payees.new(params[:payee])
    if @payee.save
      redirect_to redirect_target(@account)
    else
      if @account
        @payees = @account.payees.uniq.sort_by { |p| -p.use_count }
      else
        @payees = current_user.payees.sort_by { |p| -p.use_count }
      end
      @categories = current_user.all_categories
      render :action => 'index'
    end
  end

  def show
    current_user = get_current_user
    @account = Account.from_params(params)
    @year = Year.from_params(params)
    @payee = Payee.find(params[:id])
    authenticate_user(@payee.user_id) or return
    @tax_item = TaxItem.from_params(params)
    if @tax_item
      # XXX - no route for this currently, do payee/x/tax_items/y instead
      @payee_cash_flows = @tax_item.cash_flows_by_year(current_user, @year, @account, @payee, true)
    else
      @payee_cash_flows = @payee.linked_cash_flows_by_year(@account, @year)
    end
    @categories = current_user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}
  end

  def edit
    current_user = get_current_user
    @account = Account.from_params(params)
    @payee = Payee.find(params[:id])
    authenticate_user(@payee.user_id) or return
    @categories = current_user.all_categories
  end

  def update
    current_user = get_current_user
    @account = Account.from_params(params)
    @year = Year.from_params(params)
    @payee = Payee.find(params[:id])
    authenticate_user(@payee.user_id) or return
    if params[:commit] == "Update Unset"
      update_all = true
      with_override = false
    elsif params[:commit] == "Update All"
      update_all = true
      with_override = true
    else
      update_all = false
    end

    if @payee.update_attributes(params[:payee])
      if update_all
        @payee.apply_default_category(@account, @year, with_override)
      end
      redirect_to redirect_target(@account)
    else
      @account = Account.from_params(params)
      @categories = current_user.all_categories
      render :action => "edit"
      # XXX how to I return to 'source' :show or :edit ?
      #@payee_cash_flows = @payee.linked_cash_flows(@account)
      #render :action => "show"
    end
  end

  def destroy
    @account = Account.from_params(params)
    @payee = Payee.find(params[:id])
    authenticate_user(@payee.user_id) or return
    if (@payee.use_count.zero?)
      @payee.destroy
    end
    redirect_to redirect_target(@account)
  end
end
