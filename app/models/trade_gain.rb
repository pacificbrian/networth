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

  def get_basis
    # use if not storing FIFO/AVGB computed basis
    if shares.nil?
      sell_shares = sell.shares
    else
      sell_shares = shares
    end
    # should be FIFO result
    # bogus buy.amount if new splits since tg written
    return buy.amount_ps * sell_shares
  end

  def amount
    if shares.nil?
      sell_shares = sell.shares
    else
      sell_shares = shares
    end
    return (sell.amount/sell.shares) * sell_shares
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
