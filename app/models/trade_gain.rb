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

class TradeGain < ActiveRecord::Base
  #belongs_to :sell, :class_name => :trade
  #belongs_to :buy, :class_name => :trade
  validates_presence_of :sell_id
  validates_presence_of :buy_id

  def sell
    Trade.find(self.sell_id)
  end

  def buy
    Trade.find(self.buy_id)
  end

  def shares_sold
    # self.shares may not be set yet
    if shares.nil?
      return sell.shares
    end
    shares
  end

  # Can use if not storing FIFO/AVGB computed basis,
  # calculates FIFO result
  def get_basis
    # bogus buy.amount if new splits since TradeGain written
    return buy.amount_ps * shares_sold
  end

  def sell_amount
    return (sell.amount/sell.shares) * shares_sold
  end

  def gain
    return sell_amount - basis
  end

  # TODO: is this used? should call gain?
  def amount
    sell_amount
  end

  #
  # Functions below are for 'repairs' in script/console
  #

  def update_basis
    _basis = get_basis
    self.basis = _basis
    self.save
    return _basis
  end
end
