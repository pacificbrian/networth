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

#require 'fastercsv'
class QuotesController < ApplicationController
  def index
    days = nil
    if params[:company_id]
      @company = Company.find(params[:company_id])
    else
      @company = nil
    end
    @quotes = nil
    @quote_settings = nil

    if @company
      symbol = @company.symbol
      if days
        @quotes = Quote.find :all, :limit => days, :conditions => { :symbol => symbol }, :order => 'date DESC'
      else
        @quotes = Quote.find :all, :conditions => { :symbol => symbol }, :order => 'date DESC'
      end
    else
        @quote_setting = QuoteSetting.new
        @quote_settings = QuoteSetting.find :all
    end
  end

  def create
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @company.update_historical_quotes
    else
      Quote.auto_update
    end
    redirect_back
  end

  def destroy
    @quote = Quote.find(params[:id])
    @quote.destroy
    redirect_back
  end

  def chart
    @symbol = params[:id]
  end

  # example action to return the contents
  # of a table in CSV format
  def export
    days = nil
    symbol = params[:id]
    if days
      quotes = Quote.find :all, :limit => days, :conditions => { :symbol => symbol }, :order => 'date DESC'
    else
      quotes = Quote.find :all, :conditions => { :symbol => symbol }, :order => 'date DESC'
    end

    csv_string = FasterCSV.generate do |csv|
      quotes.each do |q|
        csv << [q.date,q.volume.to_i,q.close]
      end
    end
    send_data csv_string, :type => "text/csv",
                          :filename=>"nw_quote_export.csv",
                          :disposition => 'attachment'
    # :filename=>"export_#{session[:user_id]}.csv",
    # :filename=>"export_#{session.model.id}.csv",
  end
end
