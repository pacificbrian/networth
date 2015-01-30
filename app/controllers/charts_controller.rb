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

class ChartsController < ApplicationController
#  before_filter :set_current_user, :only => [ :index, :create ]

  def test_normalize(params)
    if params.key?(:normalize) # and params[:normalize] == "1"
      return true
    else
      return false
    end
  end

  def index
    current_user = get_current_user
    use_roc = true
    @normalize = test_normalize(params)

    if params[:account_id]
      @account = Account.find(params[:account_id])
      authenticate_user(@account.user_id) or return
      @name = @account.name
      if !@normalize || @account.credit?
        use_roc = false
      end
    elsif params[:company_id]
      @company = Company.find(params[:company_id])
      @name = @company.chart_label
    elsif params[:security_id]
      @security = Security.find(params[:security_id])
      authenticate_user(@security.account.user_id) or return
      @company = @security.company
      @name = @company.chart_label
    else
      @name = current_user.name
    end

    days = Day.from_params(params)
    @days = days
    # standardize on nil meaning full history
    if days.nil?
      if @account
        days = (Date.today - @account.date_opened) + 1
      elsif @security
        days = 1 + @security.days
      else
        days = 0 # for user or company, use YTD
      end
    end
    @year = Year.from_params(params)

    # get the Cashflow data into Chart form
    @points = to_points(params, nil, days)

    # work in progress Comparison chart
    @compare_points = Array.new
    if nil
    if @account
      @account.active_securities.each do |s|
        named_points = Array.new
        points = to_points(params, s.company, days)
        label = s.company.symbol
        gain = points.at(points.size - 1).at(1)
        label = label + " " + gain.round(2).to_s + "%"
        named_points.push(label)
        named_points.push(points)
        @compare_points.push(named_points)
      end
    end
    if @company
        named_points = Array.new
        named_points.push(@company.chart_label)
        named_points.push(to_points(params, @company, days))
        @compare_points.push(named_points)
    end
    end

    if use_roc && !@points.empty?
      points = @points
      first_price = points.at(0).at(1)
      last_price = points.at(points.size - 1).at(1)
      puts first_price.to_s + " => "+ last_price.to_s
      gain = ((last_price - first_price) / first_price) * 100
      @name = @name + " " + gain.round(2).to_s + "%"
    end

    respond_to do |format|
        format.html
        format.json { @points.to_json }
    end
  end

  def values_to_points(values, end_date)
    return values_dates_to_points(values, nil, end_date)
  end

  def values_dates_to_points(values, dates, end_date)
    # use values.size rather than number of days because can't assume
    # we were returned the number of days we requested
    points = Array.new
    # (end_date - d) usage here assumes contiguous span of days in @values
    #  TODO this is broken and we can't assume contiguous span of Quotes,
    #    has to use q.get_date in this main loop here
    d = values.size - 1
    s = 0
    values.each do |v|
        if nil
        if (end_date - d).wday > 5
          # skip Sat and Sun which don't have Quotes
          # TODO holidays?
          d -= 1
          next
        end
        end
        point = Array.new
        #cannot use dates because chart assumes linear range (days only 0-31)
        #point.push(end_date_offset - d)
        # JS time
        if (dates.nil?)
          point.push((end_date - d).to_time.strftime("%s").to_i * 1000)
          puts (end_date - d).strftime("%m %d %y %s")
        else
          point.push(dates[s].to_time.strftime("%s").to_i * 1000)
          puts (dates[s]).strftime("%m %d %y %s")
        end
        d -= 1
        s += 1
        point.push(v.to_f)
        points.push(point)
    end
    return points
  end

  def to_points(params, company, days)
    current_user = get_current_user
    normalize = test_normalize(params)

    use_roc = false
    if company
      normalize = false
      use_roc = true
    elsif params[:account_id]
      account = Account.find(params[:account_id])
    elsif params[:company_id]
      company = Company.find(params[:company_id])
    elsif params[:security_id]
      security = Security.find(params[:security_id])
      company = security.company
    end

    # TODO: extra days calculation from SecurityController
    #if start_date.wday.zero?
    #  days += 2
    #end

    end_date = Date.today
    end_date_offset = 0
    if days.zero?
      start_date = Date.new(end_date.year)
      days = 1 + (end_date - start_date).to_i
    else
      start_date = end_date - days
    end

    if account
      values = account.by_date_range(end_date, days, normalize)
      points = values_to_points(values, end_date)
    #elsif security
    # TODO: security should show Security balance? (price * shares)?
    # values = security.by_date_range(end_date, days, normalize)
    elsif company
      #points = company.to_points(end_date, days)
      values = Array.new
      volume = Array.new
      dates = Array.new
      # wrong if Quotes missing Dates upto Date.today
      quotes = Quote.range_from_company(company, end_date - days)

      # if Quotes doesn't reach end_date, add padding
      # (end_date - d) usage below assumes contiguous span of days in values
      d = 0
      if quotes.empty?
        #if (end_date - d) >= start_date
        while (end_date - d) >= start_date
          if (end_date - d).wday > 0 && (end_date - d).wday < 6
            if company.price
              values << company.price
              volume << 0
              dates << (end_date - d)
            end
          end
          d += 1
        end
      else
        q = quotes[0]
        #if (end_date - d) != q.get_date
        while (end_date - d) != q.get_date
          if (end_date - d).wday > 0 && (end_date - d).wday < 6
            #values.insert(0, company.price)
            values << q.adjclose
            volume << q.volume
            dates.insert(0, (end_date - d))
          end
          d += 1
        end
      end

      d = 0
      quotes.each do |q|
        if nil
        # add padding for missing Sat, Sun
        # - TODO  Holidays?
        if d != 0 && q.get_date.wday == 5
          values.insert(0, q.adjclose)
          volume.insert(0, q.volume)
          values.insert(0, q.adjclose)
          volume.insert(0, q.volume)
        end
        end
        values.insert(0, q.adjclose)
        volume.insert(0, q.volume)
        dates.insert(0, q.get_date)
        d += 1
      end

      if use_roc && values
        first = values.at(0)
        roc_values = Array.new
        values.each do |v|
          r = (((v - first) * 100) / (first))
          r = (r * 1000).to_i
          roc_values.push(r / 1000.0) 
        end
        values = roc_values
      end
      points = values_dates_to_points(values, dates, end_date)
    else # User
      values = current_user.by_date_range(end_date, days, normalize)
      points = values_to_points(values, end_date)
    end

    return points
  end
end
