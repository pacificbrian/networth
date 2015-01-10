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

class TaxesController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :create ]

  def index
    current_user = User.find(session[:user_id])
    @tax = current_user.taxes.new
    @year = params[:year_id]
    #@taxes = current_user.taxes.by_year(@year, true)
    @account = Account.from_params(params)
    if @account
      @taxes = @tax.auto_tax(@year, nil, @account)
    else
      @taxes = @tax.taxes_by_year(@year, true)
    end

    if @year
      @show_tax_items = true
      @tax.year = Date.ordinal(@year.to_i)
      @tax_results = current_user.tax_users.find_all_by_year(@year)
    else
      @tax.year = (Date.today << 6)
      @tax_results = current_user.tax_users
    end
    @tax_result = TaxUser.new
    # TODO, fix container for TaxUser.year
    #@tax_result.year = @tax.year
    @tax_result.year = @tax.year.year
    @tax_filing_status = TaxUser.filing_status_to_s
    @tax_regions = TaxRegion.find(:all)
    @tax_types = TaxType.find(:all)
    @tax_items = TaxItem.find(:all)
  end

  def create
    current_user = User.find(session[:user_id])
    @tax = current_user.taxes.new(params[:tax])
    @year = params[:year_id]
    if @tax.save
      if @year
        redirect_to year_taxes_path(@year)
      else
        redirect_to taxes_path
      end
    else
      @taxes = @tax.taxes_by_year(@year, true)
      @tax_regions = TaxRegion.find(:all)
      @tax_types = TaxType.find(:all)
      @tax_items = TaxItem.find(:all)
      render :action => 'index'
    end
  end

  def edit
    @tax = Tax.find(params[:id])
    @year = params[:year_id]
    @tax_regions = TaxRegion.find(:all)
    @tax_types = TaxType.find(:all)
    @tax_items = TaxItem.find(:all)
  end

  def update
    @tax = Tax.find(params[:id])
    @year = params[:year_id]
    if @tax.update_attributes(params[:tax])
      if @year
        redirect_to year_taxes_path(@year)
      else
        redirect_to taxes_path
      end
    else
      @tax_regions = TaxRegion.find(:all)
      @tax_types = TaxType.find(:all)
      @tax_items = TaxItem.find(:all)
      render :action => "edit"
    end
  end

  def destroy
    @tax = Tax.find(params[:id])
    @year = params[:year_id]
    @tax.destroy
    if @year
      redirect_to year_taxes_path(@year)
    else
      redirect_to taxes_path
    end
  end
end
