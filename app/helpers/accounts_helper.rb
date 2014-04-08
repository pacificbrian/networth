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

module AccountsHelper
  def chart_account_url_days(who, days)
    if who.nil?
      chart_accounts_url(:days => days.to_i)
    else
      chart_account_url(who, :days => days.to_i)
    end
  end

  def chart_account_url_months(who, months)
    days = Date.today - (Date.today << months)
    if who.nil?
      chart_accounts_url(:days => days.to_i)
    else
      chart_account_url(who, :days => days.to_i)
    end
  end

  def chart_account_url_years(who, years)
    days = Date.today - Date.today.years_ago(years)
    if who.nil?
      chart_accounts_url(:days => days.to_i)
    else
      chart_account_url(who, :days => days.to_i)
    end
  end

  def account_charts_url_days(who, days, normalize=nil)
    opts = Hash[:days, days.to_i]
    opts[:normalize] = 1 if normalize
    if who.nil?
      accounts_charts_path(opts)
    else
      account_charts_path(who, opts)
    end
  end

  def account_charts_url_months(who, months, normalize=nil)
    days = Date.today - (Date.today << months)
    opts = Hash[:days, days.to_i]
    opts[:normalize] = 1 if normalize
    if who.nil?
      accounts_charts_path(opts)
    else
      account_charts_path(who, opts)
    end
  end

  def account_charts_url_years(who, years, normalize=nil)
    days = Date.today - Date.today.years_ago(years)
    opts = Hash[:days, days.to_i]
    opts[:normalize] = 1 if normalize
    if who.nil?
      accounts_charts_path(opts)
    else
      account_charts_path(who, opts)
    end
  end
end
