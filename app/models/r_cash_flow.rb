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

class RCashFlow < CashFlow
  belongs_to :account
  belongs_to :payee
  belongs_to :repeat_interval

  validates_presence_of :date
  validates_presence_of :category_id
  validates_presence_of :payee_id
  validates_numericality_of :amount

  attr_accessor :repeat_interval_type_id
  attr_accessor :repeats_left, :rate
  attr_accessible :repeat_interval_type_id, :repeats_left, :rate

  #self.inheritance_column = "cash_flow_type"

  def self.params_to_cf(params)
    new_cf = RCashFlow.new
    new_cf.params_to_cf(params)
    if new_cf && new_cf.transnum == "0"
      new_cf.transnum = nil
    end
    return new_cf
  end

  def self.fetch(_id)
    cash_flow = RCashFlow.find(_id)
    if cash_flow
      cash_flow.repeat_interval_type_id = cash_flow.repeat_interval.repeat_interval_type_id
      cash_flow.repeats_left = cash_flow.repeat_interval.repeats_left
      return cash_flow.set_defaults
    end
  end

  def self.process_by_account(account)
    r_cash_flows = account.ordered_r_cash_flows.reverse
    if r_cash_flows.empty?
      return nil
    end
    first_cf = r_cash_flows[0]
    if (Date.today < first_cf.date)
      # Scheduled CFs are in the future
      return nil
    end

    account.delete_saved_balances(first_cf.date)
    r_cash_flows.each do |rcf|
puts "processing Scheduled for Payee " + rcf.get_payee_name
      rcf.record_cash_flow
    end
  end

  def self.process_by_user(user)
    accounts = user.accounts
    unless accounts
      return nil
    end
    accounts.each do |a|
      RCashFlow.process_by_account(a)
    end
  end

  def is_editable?
    not (has_splits?)
  end

  def add_repeat_interval
    ri = RepeatInterval.new()
    ri.repeat_interval_type_id = self.repeat_interval_type_id
    ri.repeats_left =  self.repeats_left
    ri.cash_flow_id = self.id
    ri.save
    self.repeat_interval_id = ri.id
    self.save
  end

  def update_repeat_interval
    ri = self.repeat_interval
    if ri.nil?
      return self.add_repeat_interval
    end
    ri.repeat_interval_type_id = self.repeat_interval_type_id
    ri.repeats_left =  self.repeats_left
    ri.cash_flow_id = self.id
    ri.save
  end
end
