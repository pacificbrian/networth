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

class TaxItem < ActiveRecord::Base
  has_many :tax_categories
  #has_many :categories, :through => :tax_categories
  #has_many :cash_flows, :through => :categories
  attr_accessible :name

  #def tax_categories
  #  TaxCategory.find_all_by_tax_item_id(id)
  #end

  def self.from_params(params)
    if (params[:tax_item_id])
      TaxItem.find(params[:tax_item_id])
    else
      return nil
    end
  end

  def has_trades?
    return true if name == "Capital Gain"
  end

  def auto_tax(year, account=nil)
    new_tax = nil

    unless year
      return new_tax
    end
    d1 = Date.ordinal(year.to_i)
    d2 = Date.ordinal(year.to_i + 1)
    user = User.find(1)

    ti_cf = cash_flows_by_year(year, account)
    if !ti_cf.empty?
      new_tax = user.taxes.new
      new_tax.tax_type_id = tax_type_id
      new_tax.tax_item_id = id
      new_tax.tax_region_id = 1
      new_tax.year = d1
      new_tax_amount = 0

      ti_cf.each do |t|
        if (new_tax.tax_type.negative_auto_values?)
          # only accept negative values, and convert
          if (t.amount < 0)
            new_tax_amount += (t.amount * -1)
          end
        else
          new_tax_amount += t.amount
        end
      end
      new_tax.amount = new_tax_amount

      new_tax.memo = "AUTO"
    end
    return new_tax
  end

  def cash_flows_by_year(year, account=nil, payee=nil, include_user_ti=false)
    cfs = Array.new
    unless tax_categories
      return cfs
    end

    # if not account specific, include user provided TI if requested
    if (account.nil? && include_user_ti)
      user = User.find(1)
      ti_array = Tax.taxes_by_year(year, false, nil, id)
      ti_array.each do |ti|
        new_cf = user.cash_flows.new
        new_cf.date = Date.new(ti.year.year, 12, 31)
        new_cf.amount = ti.amount
        new_cf.memo = ti.memo
        #new_cf.account_id = ti.account_id
        new_cf.payee_name = "User Tax Item"
        new_cf.category_id = tax_categories[0].category_id
        cfs.push new_cf
      end
    end

    if year
      d1 = Date.ordinal(year.to_i)
      d2 = Date.ordinal(year.to_i + 1)
    end

    user = User.find(1)
    tax_categories.each do |tc|
      if tc.trade_type_id
        cfs.concat user.ordered_gain_cashflows_by_year(year, tc.trade_type_id, account, true)
      else
        if account
          c_array = account.cash_flows
        else
          c_array = user.cash_flows
        end

        if year
          cfs.concat c_array.find :all, 
                           :conditions => [ 'category_id = ? AND tax_year = ?',
                                            tc.category_id, year.to_i ]
        else
          cfs.concat c_array.find :all, 
                           :conditions => [ 'category_id = ?', tc.category_id ]
        end
      end
    end

    cfs.delete_if { |cf| cf.payee_id != payee.id } if payee
    cfs.delete_if { |cf| cf.account != nil && !cf.account.taxable }
    return cfs.sort_by { |cf| cf.date.jd }
  end

  def cash_flows
    cash_flows_by_year(nil)
  end
end
