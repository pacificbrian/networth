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

class TaxUsersController < ApplicationController
  before_filter :set_current_user, :only => [ :create ]

  def create
    current_user = User.find(session[:user_id])
    @tax_user = current_user.tax_users.new(params[:tax_user])
    @year = params[:year_id]
    @tax_user.save
    if @year
      redirect_to year_taxes_path(@year)
    else
      redirect_to taxes_path
    end
  end

  def edit
    @tax_user = TaxUser.find(params[:id])
    @year = params[:year_id]
    @tax_filing_status = TaxUser.filing_status_to_s
    @tax_regions = TaxRegion.find(:all)
  end

  def update
    @tax_user = TaxUser.find(params[:id])
    @year = params[:year_id]
    redirect_to_taxes_path = false

    @edit_tax_user = params[:tax_user]
    if @edit_tax_user.nil?
      @tax_user.recalculate
      redirect_to_taxes_path = true
    else
      if @tax_user.update_attributes(@edit_tax_user)
        redirect_to_taxes_path = true
      else
        @tax_filing_status = TaxUser.filing_status_to_s
        @tax_regions = TaxRegion.find(:all)
        render :action => "edit"
      end
    end

    if redirect_to_taxes_path
      if @year
        redirect_to year_taxes_path(@year)
      else
        redirect_to taxes_path
      end
    end
  end

  def destroy
    @tax_user = TaxUser.find(params[:id])
    @year = params[:year_id]
    @tax_user.destroy
    if @year
      redirect_to year_taxes_path(@year)
    else
      redirect_to taxes_path
    end
  end
end
