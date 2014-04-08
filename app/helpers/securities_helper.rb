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

module SecuritiesHelper
  def chart_security_url_days(who, days)
    chart_security_url(who, :days => days.to_i)
  end

  def chart_security_url_months(who, months)
    days = Date.today - (Date.today << months)
    chart_security_url(who, :days => days.to_i)
  end

  def chart_security_url_years(who, years)
    days = Date.today - Date.today.years_ago(years)
    chart_security_url(who, :days => days.to_i)
  end

  def security_charts_url_days(who, days)
    if days.nil?
      security_charts_path(who)
    else
      security_charts_path(who, :days => days.to_i)
    end
  end

  def security_charts_url_months(who, months)
    days = Date.today - (Date.today << months)
    security_charts_path(who, :days => days.to_i)
  end

  def security_charts_url_years(who, years)
    days = Date.today - Date.today.years_ago(years)
    security_charts_path(who, :days => days.to_i)
  end

end
