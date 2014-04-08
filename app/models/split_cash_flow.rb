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

class SplitCashFlow < CashFlow
  belongs_to :account
  belongs_to :cash_flow, :foreign_key => "split_from"

  validates_presence_of :date
  validates_presence_of :category_id
  validates_presence_of :payee_id
  validates_numericality_of :amount

  def attach_transfer?
    if self.cash_flow.repeat?
      return false
    end
    return true
  end

  def self.update_type
    scfs = CashFlow.find(:all, :conditions => { :split => true })
    scfs.each do |scf|
      scf.type = "SplitCashFlow"
      scf.save
    end
  end

  def self.params_to_cf(params)
    new_cf = SplitCashFlow.new
    return new_cf.params_to_cf(params)
  end
end
