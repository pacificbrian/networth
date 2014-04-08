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

module CompaniesHelper
  def chart_company_url_days(who, days)
    chart_company_url(who, :days => days.to_i)
  end

  def chart_company_url_months(who, months)
    days = Date.today - (Date.today << months)
    chart_company_url(who, :days => days.to_i)
  end

  def chart_company_url_years(who, years)
    days = Date.today - Date.today.years_ago(years)
    chart_company_url(who, :days => days.to_i)
  end

  def company_charts_url_days(who, days)
    company_charts_path(who, :days => days.to_i)
  end

  def company_charts_url_months(who, months)
    days = Date.today - (Date.today << months)
    company_charts_path(who, :days => days.to_i)
  end

  def company_charts_url_years(who, years)
    days = Date.today - Date.today.years_ago(years)
    company_charts_path(who, :days => days.to_i)
  end
end
