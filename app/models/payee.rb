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

class Payee < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :cash_flows
  validates_presence_of :name
  attr_accessible :name, :address, :category_id, :skip_on_import

  def self.from_params(params)
    if (params[:payee_id])
      Payee.find(params[:payee_id])
    else
      return nil
    end
  end

  def linked_cash_flows_by_year(account, year)
    linked_cash_flows(account, year)
  end

  def linked_cash_flows(account=nil, year=nil)
    cfs = self.cash_flows.delete_if {|c| c.transfer ||
	    		(account && c.account_id != account.id) ||
			(year && c.date.year != year) }
    cfs.delete_if {|c| c.repeat?}
    #cfs.sort_by {|c| c.date}
    return cfs
  end

  def set_use_count
    c = self.linked_cash_flows.size
    self.cash_flow_count = c
    self.save
  end

  def use_count(account=nil)
    #return self.linked_cash_flows(account).size
    if account.nil?
      if self.cash_flow_count.nil?
        self.set_use_count
      end
      self.cash_flow_count
    else
      self.linked_cash_flows(account).size
    end
  end

  def in_use?(update=false)
    self.set_use_count if update
    if self.use_count.zero?
      false
    else
      true
    end
  end

  def apply_default_category(account = nil, year = nil, override=false)
    count = 0
    if self.category_id.nil?
      return count
    end

    cfs = self.linked_cash_flows_by_year(account, year)
    cfs.each do |c|
      if (override or (c.category_id.nil? or c.category_id == 1)) and not c.has_splits?
        c.category_id = self.category_id
        c.save
        count = count + 1
      end
    end
    puts "Updated payee count: " + count.to_s

    return count
  end

  def merge_with(payee_id, and_delete=false)
    cfs = self.linked_cash_flows
    n = 0
    cfs.each do |c|
      c.payee_id = payee_id
      c.save
      n = n + 1
    end
    if not and_delete
      return n
    end
    cfs = self.cash_flows.delete_if {|c| c.transfer}
    if cfs.size == 0
      self.delete
    end
    return n
  end
end
