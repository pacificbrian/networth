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

class Tax < ActiveRecord::Base
  belongs_to :user
  belongs_to :tax_type
  belongs_to :tax_item
  belongs_to :tax_region
  validates_presence_of :amount
  attr_accessible :year, :tax_region_id, :tax_type_id, :tax_item_id, :memo, :amount

  def +(obj)
    amount + obj.amount
  end

  def self.auto_tax(user, year, tax_region_id=nil, type_id=nil, account=nil)
    taxes = Array.new
    if year.nil?
      return taxes
    end

    tax_items = TaxItem.find(:all)
    tax_items.each do |ti|
      tax = nil
      if !type_id || (type_id == ti.tax_type_id)
        tax = ti.auto_tax(user, year, tax_region_id, account)
      end

      if tax
        taxes.push tax
      end
    end
    return taxes
  end

  def self.taxes_by_year(user, year, auto_taxes=false, type_id=nil, item_id=nil)
    taxes = Array.new
    if auto_taxes
      taxes.concat self.auto_tax(user, year, auto_taxes, type_id)
    end
    taxes.concat user.taxes_by_year(year, type_id, item_id)
    return taxes
  end

  def auto_tax(year, type_id=nil, account=nil)
    Tax.auto_tax(user, year, false, type_id, account)
  end

  def taxes_by_year(year, auto_taxes=false, type_id=nil, item_id=nil)
    Tax.taxes_by_year(user, year, auto_taxes, type_id, item_id)
  end

  def cash_flows_by_year(year)
    unless tax_item.tax_categories
      return Array.new
    end
    cfs = tax_item.cash_flows_by_year(user, year)
    return cfs.sort_by { |cf| cf.date.jd }
  end

  def tax_region_name
    if tax_region_id == 0
      "ANY"
    else
      tax_region.name
    end
  end
end
