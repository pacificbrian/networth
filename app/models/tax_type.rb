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

class TaxType < ActiveRecord::Base
  has_many :tax_items
  attr_accessible :name

  def negative_auto_values?
    # Itemized, Credits, Payments
    if (id == 5 || id == 7 || id == 8)
      return true
    else
      return false
    end
  end

  def cash_flows_by_year(year)
    cfs = Array.new
    tax_items.each do |i|
      cfs.concat i.cash_flows_by_year(year)
    end
    return cfs.sort_by { |cf| cf.date.jd }
  end

  def cash_flows
    cash_flows_by_year(nil)
  end
end
