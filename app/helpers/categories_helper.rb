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

module CategoriesHelper
  def category_url_days(who, c, days)
   if days.nil?
    if c.nil?
      if who.nil?
        categories_url
      else
        account_categories_url(who)
      end
    else
      if who.nil?
        category_url(c)
      else
        account_category_url(who, c)
      end
    end
   else
    if c.nil?
      if who.nil?
        categories_url(:days => days.to_i)
      else
        account_categories_url(who, :days => days.to_i)
      end
    else
      if who.nil?
        category_url(c, :days => days.to_i)
      else
        account_category_url(who, c, :days => days.to_i)
      end
    end
   end
  end

  def category_url_months(who, c, months)
    days = Date.today - (Date.today << months)
    category_url_days(who, c, days)
  end

  def category_url_years(who, c, years)
    days = Date.today - Date.today.years_ago(years)
    category_url_days(who, c, days)
  end
end
