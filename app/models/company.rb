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

class Company < ActiveRecord::Base
  has_many :securities

  attr_accessor :security_type_id
  attr_accessor :security_basis_type_id

  def basis=(x)
    @basis = x
  end
  def value=(x)
    @value = x
  end

  def shares_held
    shares = 0
    securities.each do |s|
      if !s.account.watchlist
        shares = shares + s.shares
      end
    end
    return shares
  end

  def is_forex
    if self.symbol
      return self.symbol.slice("=X")
    else
      return nil
    end
  end

  # XXX these two functions need to be replaced with something better
  def is_fund
    if self.symbol
      return (self.symbol.split("-")[0].length > 4)
    else
      return nil
    end
  end

  def has_valid_symbol
    if self.symbol
      return (self.symbol.split("-")[0].length < 6)
    else
      return nil
    end
  end

  def chart_label
      if (name == symbol)
        return name
      else
        return name + " (" + symbol + ")"
      end
  end

  def self.create_from_symbol(symbol, fast=false)
    symbol = Company.create(:name => symbol, :symbol => symbol)
    if not fast
      symbol.update_historical_quotes
    end
    return symbol
  end

  def self.create_from_name(name)
    symbol = Company.create(:name => name, :symbol => nil)
    return symbol
  end

  def quote_update_command
    if self.is_forex
      return Quote.update_forex_command(symbol)
    else
      return Quote.update_command(symbol)
    end
  end

  def update_historical_quotes
    if self.has_valid_symbol
      #exec(self.quote_update_command) if fork.nil?
      p = IO.popen(self.quote_update_command)
      puts p.readlines
      p.close
    end
  end

  def price(fetch=false)
    if self.has_valid_symbol
      q = Quote.current_from_company(self, fetch)
      if q.nil?
        return nil
      end
      q.close
    end
  end
end
