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

class AccountType < ActiveRecord::Base
  attr_accessible :name
  def investment?
    (self.name == 'Investment')
  end

  def deposit?
    (self.name == 'Checking/Deposit')
  end

  def credit?
    (self.name == 'Credit Card')
  end

  def loan?
    (self.name == 'Loan')
  end

  def health?
    (self.name == 'Health Care')
  end

  def asset?
    (self.name == 'Asset')
  end

  def get_icon_path
    t = self
    if t.investment?
      "icn_investments.png"
    elsif  t.deposit?
      "icn_small_deposit.png"
    elsif  t.credit?
      "icn_small_credit_card.gif"
    elsif  t.health?
      "icn_health.png"
    elsif  t.asset?
      "icn_home.png"
    elsif  t.loan?
      "icn_home.png"
    else
      nil
    end
  end
end
