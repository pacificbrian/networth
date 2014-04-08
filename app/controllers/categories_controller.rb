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

class CategoriesController < ApplicationController
  before_filter :set_current_user, :only => [ :index, :show ]

  def redirect_target(account)
    if account
      account_categories_path(account)
    else
      categories_path
    end
  end

  def cashflows_to_pie_items(pie_cashflows, pie_categories, credit, omit_items=false, cap_other_size=true)
    categories_sum = Array.new
    total = 0
    total_items = 0
    total_single_items = 0
    if credit
      debit = false
    else
      debit = true
    end

    pie_cashflows.each do |category_cf|
      sum = sum_amount(category_cf)
      if debit #and (sum < 0)
         sum = -1 * sum
      end
      total += sum
      total_items += category_cf.size
      if category_cf.size == 1
        total_single_items += 1
      end
    end

    if total <= 0
      return categories_sum 
    end

    other_items = Array.new
    count = 0
    other_sum = 0
    other_count = 0
    other_size = 0
    pie_cashflows.each do |category_cf|
      cur_pie_category = pie_categories[count]
      count += 1

      sum = sum_amount(category_cf)
      if debit #and (sum < 0)
         sum = -1 * sum
      end

      if omit_items and cur_pie_category.omit_from_pie?
        total -= sum
        next
      end 

      pair = Array.new
      pair << cur_pie_category.name + " (" + category_cf.size.to_s + ")"
      pair << sum.to_f

      # consolidate minority pie items
      #  if an 'opposite' cashflow (ie. positive expense cashflow),
      #  also put here (remember we made all cashflows positive already,
      #  so this is all negative cashflows then)
      #  TODO: maybe should just ignore these?
      if (sum < 0) or (sum > 0 and (sum < (total * 0.03)))
        other_sum += sum 
        other_count += 1
        other_size += category_cf.size
        pair << category_cf.size
        other_items << pair
      elsif (not sum.zero?)
        categories_sum.push(pair)
      end
    end

    if cap_other_size
      while (other_sum > (total * 0.15))
        si = other_items.sort_by { |o| -o[1] }
        o = si[0]
        pair = Array.new
        pair << o[0]
        pair << o[1].to_f
        other_sum -= o[1]
        other_size -= o[2]
        other_count -= 1
        other_items.delete(o)
        categories_sum.push(pair)
      end
    end

    if (other_count == 1)
      pair = other_items[0]
      sum = pair[1]
      if (not sum.zero?)
        categories_sum.push(pair)
      end
    elsif (other_sum > 0)
      pair = Array.new
      #pair << "Other (" + other_count.to_s + ", " + other_sum.to_s + ")"
      pair << "Other (" + other_size.to_s + ")"
      pair << other_sum.to_f
      categories_sum.push(pair)
    end

    return categories_sum.sort_by { |pair| -pair[1] }
  end


  def index
    current_user = User.find(session[:user_id])
    @account = Account.from_params(params)
    @days = (params[:days])

    # days.nil? gives full history
    if @days
      days = @days.to_i
      # days=0 gives YTD history
      if days.zero?
        days = (Date.today - Date.new(Date.today.year)) + 1
      end
    end

    in_categories = current_user.get_categories(2)
    out_categories = current_user.get_categories(1)
    if @account
      @in_cashflows = @account.cashflows_by_category(2, days, true)
      @out_cashflows = @account.cashflows_by_category(1, days, true)
      @chart_name = @account.name
    else
      @in_cashflows = Category.categories_to_cashflows(in_categories, days, true)
      @out_cashflows = Category.categories_to_cashflows(out_categories, days, true)
      @chart_name = current_user.name
    end

    @income = cashflows_to_pie_items(@in_cashflows, in_categories, true)
    @expenses = cashflows_to_pie_items(@out_cashflows, out_categories, false, true)
    @in_cashflows = @in_cashflows.sort_by { |cf| -sum_amount(cf) }
    @out_cashflows = @out_cashflows.sort_by { |cf| sum_amount(cf) }

    if days
      json_url = "categories/json?days="+days.to_s+";"
    else
      json_url = "categories/json?"
    end
  end

  def show
    cid = params[:id]
    @category = Category.find(cid)
    @category_types = CategoryType.find(:all)
    @cash_flows = nil
    @account = Account.from_params(params)
    @year = Year.from_params(params)
    current_user = User.find(session[:user_id])
    @days = (params[:days])
    @categories = current_user.all_categories
    @inplace_categories = @categories.map {|c| [c.id, c.name]}

    # days.nil? gives full history
    if @days
      days = @days.to_i
      # days=0 gives YTD history
      if days.zero?
        days = (Date.today - Date.new(Date.today.year)) + 1
      end
    end

    if @year
      last = Date.new(@year + 1) - 1
      if days.nil?
        days = last - Date.new(@year) + 1
      end
    else
      last = Date.today
    end

    if @account
      @cash_flows = @account.cash_flows.by_range(last, days, cid)
      @chart_name = @account.name + " :: " + @category.name
    else
# TODO - this is broken for _past_ years in URL? (also use 'last' here?)
      @cash_flows = current_user.cash_flows.by_category(cid, days)
      @chart_name = current_user.name + " :: " + @category.name
    end
    # cashflows not sorted by date!

    if @cash_flows.size.nonzero?
      monthly = CashFlow.by_month(@cash_flows, @category.credit?)
      @totals = monthly[0]
      @totals_max = monthly[1]
      @totals_min = monthly[2]
      @totals_max += @totals_max * 0.15
      @totals_min -= @totals_min.abs * 0.15

      if @totals_min < 0 and @totals_max.zero?
        @totals_max = -1 * @totals_min
        @totals_min = 0
        @totals.each do |t|
          t[1] = t[1] * -1
        end
      end
    else
      @totals = Array.new
      @totals_max = 10
      @totals_min = 0
    end
    # TODO - calculate from min,max
    @bar_width = 1200000000;

    if days
      json_url = cid.to_s + "/json?days="+days.to_s
    else
      json_url = cid.to_s + "/json"
    end
  end

  def json_pie(params)
    current_user = User.find(session[:user_id])
    @account = Account.from_params(params)
    category_type = params[:category_type_id]
    days = (params[:days])

    if @account
      chart_categories = @account.get_categories(category_type.to_i)
      chart_cashflows = @account.cashflows_by_category(category_type.to_i, days)
      name = @account.name + ":" + CategoryType.find(category_type.to_i).name
    else
      chart_categories = current_user.get_categories(category_type.to_i)
      chart_cashflows = Category.categories_to_cashflows(chart_categories, days)
      name = current_user.name + ":" + CategoryType.find(category_type.to_i).name
    end

    chart_categories_sum = Array.new
    chart_cashflows.each do |category_cf|
      chart_categories_sum.push(sum_amount(category_cf))
    end

    chart = Chart.pie(name, chart_categories, chart_categories_sum, days)
    render :text => chart.render
  end

  def json_bar(params)
    @category = Category.find(params[:id])
    current_user = User.find(session[:user_id])
    @account = Account.from_params(params)
    days = (params[:days])

    if @year
      last = Date.new(@year + 1) - 1
      if days.nil?
        days = last - Date.new(@year) + 1
      end
    else
      last = Date.today
    end

    if @account
      cash_flows = @account.cash_flows.by_range(last, days, @category.id)
      #cash_flows = @account.cash_flows.find_all_by_category_id(params[:id])
      name = @account.name + ":" + @category.name
    else
      cash_flows = current_user.cash_flows.by_category(@category.id, days)
      #cash_flows = current_user.cash_flows.find_all_by_category_id(params[:id])
      name = current_user.name + ":" + @category.name
    end

    #chart = Chart.bar_3d(name, cash_flows, last, days)
    chart = Chart.bar_3d(name, cash_flows, days)
    render :text => chart.render
  end

  def json
    if (params[:id])
      return json_bar(params)
    else
      return json_pie(params)
    end
  end
end
