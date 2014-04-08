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

class SecuritiesController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :all, :show ]

  def show
    @security = Security.find(params[:id])
    @security.update_value
    @trade = Trade.new
    @trade_types = TradeType.find(:all)

    respond_to do |format|
        format.json {
            chart_json = to_json
            render :json => chart_json.render
        }
        format.html
    end
  end

  def index
    current_user = User.find(session[:user_id])
    securities = current_user.update_security_values
    @securities = securities.sort_by { |s| [s.account_id, s.get_name] }
  end

  def all
    current_user = User.find(session[:user_id])
    current_user.update_security_values
    securities = current_user.securities.find(:all)
    @securities = securities.sort_by { |s| [s.account_id, s.get_class, s.get_name] }
  end

  def edit
    @security = Security.find(params[:id])
    @security.symbol = @security.company.symbol
    @security.name = @security.company.name
    @security_types = SecurityType.find(:all)
    @security_basis_types = SecurityBasisType.find(:all)
  end

  def update
    @security = Security.find(params[:id])
    @security.company.update_attributes(params[:security])
    @security.update_attributes(params[:security])
    @securities = @security.account.user.active_securities
    render :action => "index"
    # or :action => "show"
  end

  def destroy
    @security = Security.find(params[:id])
    @account = @security.account
    #@security.destroy
    redirect_to @account
  end

  def to_json
    days = nil
    values = Array.new
    dates = Array.new

    security = Security.find(params[:id])
    if params[:days]
      days = params[:days].to_i
      if days.zero?
        days = nil
      else
        start_date = Date.today - days
      end
    end

    unless days
      start_date = Date.new(Date.today.year)
      days = 365
    end

    quotes = Quote.range_from_security(security, start_date)

    last_price = 0
    vmin = vmax = nil
    quotes.each do |q|
      if (vmin.nil?)
        vmin = vmax = q.adjclose
        last_price = q.adjclose
      end

      values.insert(0, q.adjclose)
      if q.adjclose < vmin
        vmin = q.adjclose
      end
      if q.adjclose > vmax
        vmax = q.adjclose
      end

      if days > 365
        dates.insert(0, q.date.strftime("%y %b %d"))
      else
        dates.insert(0, q.date.strftime("%b %d"))
      end
    end
    first_price = values.at(0)

    puts first_price.to_s + " => "+ last_price.to_s
    gain = ((last_price - first_price) / first_price) * 100

    if (vmin.nil?)
      vmin = vmax = 0
    else
      vrange = vmax - vmin
      vmax = vmax + (vrange * 0.05)
      vmin = vmin - (vrange * 0.05)
      #vmax = (vmax * 10).round / 10
      #vmin = (vmin * 10).round / 10
    end

    name = security.company.symbol
    return Chart.dateline(name + " " + gain.round(2).to_s + "%",
                          dates, values, vmin, vmax)
  end

  def json
    chart_json = to_json
    render :json => chart_json.render
  end

  def chart
    if params[:id]
      @security = Security.find(params[:id])
    end

    if params[:days]
      json_url = "json?days="+ params[:days]
    else
      days = 1 + @security.days
      start_date = Date.today - days
      if start_date.wday.zero?
        days += 2
      end
      json_url = "json?days=" + days.to_s
    end

    @graph = open_flash_chart_object(720, 400, json_url)
  end
end
