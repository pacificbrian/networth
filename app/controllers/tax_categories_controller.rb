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

class TaxCategoriesController < ApplicationController
  before_filter :test_sysadmin_user

  def index
    @tax_category = TaxCategory.new
    @tax_categories = TaxCategory.find(:all)
    @categories = Category.find(:all)
    @trade_types = TradeType.find(:all)
    @tax_items = TaxItem.find(:all)
  end

  def create
    @tax_category = TaxCategory.new(params[:tax_category])
    if @tax_category.save
      tax_categories_path
    else
      @tax_categories = TaxCategory.find(:all)
      @categories = Category.find(:all)
      @trade_types = TradeType.find(:all)
      @tax_items = TaxItem.find(:all)
      render :action => 'index'
    end
  end

  def edit
    @tax_category = TaxCategory.find(params[:id])
    @categories = Category.find(:all)
    @trade_types = TradeType.find(:all)
    @tax_items = TaxItem.find(:all)
  end

  def update
    @tax_category = TaxCategory.find(params[:id])
    if @tax_category.update_attributes(params[:tax_category])
      tax_categories_path
    else
      @categories = Category.find(:all)
      @trade_types = TradeType.find(:all)
      @tax_items = TaxItem.find(:all)
      render :action => "edit"
    end
  end
end
