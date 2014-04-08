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

class QuoteSymbol < QuoteTable
  self.table_name = "quote_symbols"

  def self.update_date(s, date)
    if !table_exists?
      return true
    end

    symbol = s.company.symbol
    qs = QuoteSymbol.find_by_symbol(symbol)
    if qs
      qs.last_split = date
      return qs.save
    else
      return false
    end
  end
end
