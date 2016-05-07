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

class TaxUser < ActiveRecord::Base
# attr_accessor :year
# attr_accessor :income
# attr_accessor :for_agi
# attr_accessor :from_agi
# attr_accessor :credits
# attr_accessor :payments
# attr_accessor :agi_income
# attr_accessor :taxable_income
# attr_accessor :itemized
# attr_accessor :exemption
# attr_accessor :base_tax
# attr_accessor :other_tax
# attr_accessor :owed_tax
# attr_accessor :unpaid_tax
  belongs_to :user
  belongs_to :tax_region
  attr_accessible :year, :tax_region_id, :filing_status, :exemptions

  def self.filing_status_to_s
    return TaxFilingStatus.find(:all)
  end

  def filing_status_label
    return TaxFilingStatus.find(filing_status).label
  end

  def calculate_tax_15(income)
    return income * 0.15
  end

  def self.calculate_tax(year, status, taxable_income, capgain_income=nil)
    tu = TaxUser.new
    tu.year = year

    tfs = TaxFilingStatus.find_by_label(status)
    if tfs.nil?
      return
    end
    tu.filing_status = tfs.id if tfs

    if tu.has_attribute?(:long_capgain_income)
      tu.long_capgain_income = capgain_income
    end

    tu.calculate_tax(taxable_income)
  end

  def calculate_tax(income)
    calc_capgain_tax = false
    t = 0
    tc = TaxConstant.find(1)
    ty = TaxYear.find_by_year(year)

    if has_attribute?(:long_capgain_income) and long_capgain_income
      calc_capgain_tax = true
      income -= long_capgain_income
    end

    tax_income_l1 = ty.tax_income_l1_from_filing_status(filing_status)
    tax_income_l2 = ty.tax_income_l2_from_filing_status(filing_status)
    tax_income_l3 = ty.tax_income_l3_from_filing_status(filing_status)
    tax_income_l4 = ty.tax_income_l4_from_filing_status(filing_status)
    tax_income_l5 = ty.tax_income_l5_from_filing_status(filing_status)
    tax_income_l6 = ty.tax_income_l6_from_filing_status(filing_status)

    if (income < tc.tax_table_max)
      income -= (income % 50)
      income += 25
    end

    if (income)
      t += [income, tax_income_l1].min * tc.tax_l1_rate;
    end
    if (income > tax_income_l1)
      t += ([income, tax_income_l2].min - tax_income_l1) *
           tc.tax_l2_rate;
    end
    if (income > tax_income_l2)
      t += ([income, tax_income_l3].min - tax_income_l2) *
           tc.tax_l3_rate;
    end
    if (income > tax_income_l3)
      t += ([income, tax_income_l4].min - tax_income_l3) *
           tc.tax_l4_rate;
    end
    if (income > tax_income_l4)
      t += ([income, tax_income_l5].min - tax_income_l4) *
           tc.tax_l5_rate;
    end

    if (income > tax_income_l5)
      if (tax_income_l6.nil?)
        t += (income - tax_income_l5) * tc.tax_l6_rate;
      else
        t += ([income, tax_income_l6].min - tax_income_l5) *
             tc.tax_l6_rate;
        if (income > tax_income_l6)
          t += (income - tax_income_l6) * tc.tax_l7_rate;
        end
      end
    end

    if calc_capgain_tax
      t += long_capgain_income * tc.capgain_rate
    end

    if (income < tc.tax_table_max)
      t = t.round
    end
    return t
  end

  def sum(items)
    items.delete_if { |i| i.tax_region_id != self.tax_region_id }
    a = items.map { |i| i.amount }
    return a.sum
  end

  def self.sum(items)
    a = items.map { |i| i.amount }
    return a.sum
  end

  def self.sum_broken(items)
    total = 0
    return items.sum

    items.each do |i|
      total += i.amount
    end
    return total
  end

  def long_capgains_by_year(year, region_id, dividends)
    tax = user.taxes.new
    items = tax.taxes_by_year(year, region_id, nil, TaxItem.find_by_name("Capital Gain").id)
    capgain = sum(items)

    items = tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Long Asset Gain").id)
    items += tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Long Other").id)
    items += tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Long Carryover").id)
    items += tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Long K1").id)
    items += tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Long Distributions").id)
    lcapgain = sum(items) + dividends

    scapgain = capgain - lcapgain
    if scapgain < 0
      net = capgain
    else
      net = lcapgain
    end
    if net < 0
      net = 0
    end
    return net
  end

  def calculate_by_year(year)
    t_year = TaxYear.find_by_year(year)
    #t_info = user.tax_users.find_by_year(year)
    r = t_info = self
    if t_year.nil? || t_info.nil?
      return nil
    end

    tax = user.taxes.new

    #r.tax_region_id = 1
    r.year = year
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Income").id)
    r.income = sum(items)
    items = tax.taxes_by_year(year, false, nil, TaxItem.find_by_name("Qualified Dividends").id)
    qual_div_income = sum(items)
    r.income -= qual_div_income # double-counted, so remove from Income
    if r.has_attribute?(:long_capgain_income)
      r.long_capgain_income = long_capgains_by_year(year, r.tax_region_id, qual_div_income)
    end
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Deductions for AGI").id)
    r.for_agi = sum(items)
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Tax Credits").id)
    r.credits = sum(items)
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Tax Payments").id)
    r.payments = sum(items)
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Tax").id)
    r.other_tax = sum(items)
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Itemized Deductions").id)
    r.itemized_deduction = sum(items)

    # handled in TaxItems.auto_tax
    #r.credits *=  -1
    #r.payments *=  -1
    #r.itemized_deduction *= -1

    r.exemption = t_info.exemptions * t_year.exemption_amount
    r.standard_deduction = t_year.standard_deduction_from_filing_status(r.filing_status) + 0
    items = tax.taxes_by_year(year, r.tax_region_id, TaxType.find_by_name("Deductions from AGI").id)
    if items.empty?
      r.from_agi = [r.standard_deduction, r.itemized_deduction].max + r.exemption
    else
      # supports user-provided deduction amount, ignoring auto-calculated values
      r.from_agi = sum(items)
    end

    # TODO - test if AMT needed
    #r.amt = 0

    #
    # TAX results
    #

    r.agi_income = r.income - r.for_agi
    r.taxable_income = r.agi_income - r.from_agi

    # TODO - support saved tax
    need_base_tax = 1
    if need_base_tax
      r.base_tax = r.calculate_tax(r.taxable_income)
    end

    r.owed_tax = r.base_tax + r.other_tax - r.credits
    r.unpaid_tax = r.owed_tax - r.payments
  end

  def recalculate
    self.calculate_by_year(year)
    self.save
    return self
  end
end
