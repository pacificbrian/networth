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

class Category < ActiveRecord::Base
  belongs_to :user
  belongs_to :category_type
  has_many :cash_flows do
    def by_account(a, range)
      # XXX need function that removes category with non-zero amount
      #     XXX need to use report_cashflows!!!
      # XXX reads RCashFlows?

    if range
      last = Date.today
      first = last - range.to_i
      if (a.nil?)
      cfs = all  :conditions => [ 'transfer == ? AND date > ? AND date <= ?', false, first, last ]
      else
      cfs = all  :conditions => [ 'transfer == ? AND account_id == ? AND date > ? AND date <= ?', false, a.id, first, last ]
      end
    else
      if (a.nil?)
        cfs = all :conditions => { :transfer => false }
      else
        cfs = all :conditions => { :account_id => a.id,
				   :transfer => false }
      end
    end
    #cfs.delete_if { |cf| cf.has_splits? }
    cfs.delete_if { |cf| cf.split_from != 0 && !cf.split }
    end

    def by_account_amount(a, range)
      # XXX - improve
      #cfs = cash_flows.by_account(a, range)
    if range
      last = Date.today
      first = last - range.to_i
      if (a.nil?)
      cfs = all  :conditions => [ 'transfer == ? AND date > ? AND date <= ?', false, first, last ]
      else
      cfs = all  :conditions => [ 'transfer == ? AND account_id == ? AND date > ? AND date <= ?', false, a.id, first, last ]
      end
    else
      if (a.nil?)
        cfs = all :conditions => { :transfer => false }
      else
        cfs = all :conditions => { :account_id => a.id,
				   :transfer => false }
      end
    end
    cfs.delete_if { |cf| cf.split_from != 0 && !cf.split }

      total = 0
      cfs.each do |cf|
        #if cf.has_splits?
          total += cf.amount
        #end
      end
      return total
    end
  end

  validates_presence_of :name
  attr_accessor :account_id
  attr_accessible :name, :category_type_id

  def self.income_all(user_id=nil)
    a = Category.all :conditions => { :user_id => nil, :category_type_id => 2 }
    b = []
    if (user_id)
      b = Category.all :conditions => { :user_id => user_id, :category_type_id => 2 }
    end
    income = a + b
    categories = income.sort_by { |i| i.name }
  end

  def self.expenses_all(user_id=nil, use_detailed_expenses = true)
    a = Category.all :conditions => { :user_id => nil, :category_type_id => 1 }
    b = []
    if (user_id)
      b = Category.all :conditions => { :user_id => user_id, :category_type_id => 1 }
    end
    expenses = a + b

    if use_detailed_expenses
      a = Category.all :conditions => { :user_id => nil, :category_type_id => 3 }
      b = []
      if (user_id)
        b = Category.all :conditions => { :user_id => user_id, :category_type_id => 3 }
      end
      expenses = expenses + a + b
    end
    categories = expenses.sort_by { |e| e.name }
  end

  def self.categories_to_cashflows(categories, days, fill_all=false)
    category_cashflows = Array.new
    categories.each do |c|
      cashflows = c.cash_flows.by_account(nil, days)

      if cashflows.size
        category_cashflows.push(cashflows)
      elsif fill_all  # fill this category with nil array
        category_cashflows.push(Array.new)
      end
    end
    return category_cashflows
  end

  def self.name_from_id(id)
    cat = Category.find(id)
    if not cat.nil?
      return cat.name
    else
      return "Other"
    end
  end

  def linked_cash_flows
    cfs = self.cash_flows
    lcfs = Array.new

    cfs.each do |cf|
      if !cf.transfer
        lcfs.push(cf)
      end
    end
    return lcfs
  end

  def use_count
    self.linked_cash_flows.size
  end

  def credit?
    (self.category_type_id % 2) == 0
  end

  def debit?
    (self.category_type_id % 2) == 1
  end

  def in_use?
    if self.use_count.zero?
      false
    else
      true
    end
  end

  def is_tax_item?
    if self.id == Category.find_by_name("Taxes:Federal").id or \
       self.id == Category.find_by_name("Taxes:State").id or \
       self.id == Category.find_by_name("Taxes:Soc Sec").id or \
       self.id == Category.find_by_name("Taxes:SDI").id or \
       self.id == Category.find_by_name("Taxes:Medicare").id or \
       self.id == Category.find_by_name("Taxes:Property").id
      return true
    else
      return false
    end
  end

  def omit_from_pie?
    if is_tax_item? or self.omit_from_pie
      return true
    else
      return false
    end
  end

  def pie_count(range)
    if account_id
      account = Account.find(account_id)
      cash_flows.by_account_amount(account, range)
    else
      cash_flows.by_account_amount(nil, range)
    end
  end

  def self.monthly_date(date)
      m = date.at_beginning_of_month
      return m.to_time.strftime("%s").to_i * 1000
  end

  def self.monthly_min(totals)
    if totals.size > 0
      totals[0][0]
    else
      return Category.monthly_date(Date.today)
    end
  end

  def self.monthly_max(totals)
    if totals.size > 0
     totals[totals.size - 1][0]
    else
      return Category.monthly_date(Date.today)
    end
  end
end
