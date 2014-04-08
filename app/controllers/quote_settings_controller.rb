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

class QuoteSettingsController < ApplicationController
  def create
    @quote_setting = QuoteSetting.new(params[:quote_setting])
    @quote_setting.save
    redirect_to quotes_path
  end

  def edit
    @quote_setting = QuoteSetting.find(params[:id])
  end

  def update
    @quote_setting = QuoteSetting.find(params[:id])
    if @quote_setting.update_attributes(params[:quote_setting])
      redirect_to quotes_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @quote_setting = QuoteSetting.find(params[:id])
    quotes = Quotes.find_all_by_symbol(@quote_setting.symbol)
    Quote.delete quotes
    @quote_setting.destroy
    redirect_to quotes_path
  end

  #(download)
  def show
    @quote_setting = QuoteSetting.find(params[:id])
    Quote.update_quotes(@quote_setting.symbol)
    redirect_to quotes_path
  end
end
