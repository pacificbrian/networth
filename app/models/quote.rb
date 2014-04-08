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

class Quote < QuoteTable
  validates_presence_of :date
  validates_presence_of :symbol
  validates_presence_of :open
  validates_presence_of :close
  validates_presence_of :high
  validates_presence_of :low
  validates_presence_of :volume
  self.table_name = "quotes"

  def self.auto_update_command 
    "env RAILS_ROOT="+Rails.root.to_s + " " + Rails.root.to_s+"/app/scripts/quotes/auto_quotes.sh"
  end

  def self.update_command(symbol) 
    "env RAILS_ROOT="+Rails.root.to_s + " " + Rails.root.to_s+"/app/scripts/quotes/update_quote.sh " + symbol.to_s
  end

  def self.update_forex_command(symbol)
    "env RAILS_ROOT="+Rails.root.to_s + " " + Rails.root.to_s+"/app/scripts/quotes/update_forex.sh " + symbol.to_s
  end

  def self.auto_update
    cmd = Quote.auto_update_command
    unless cmd.nil?
      p = IO.popen(cmd)
      puts p.readlines
      p.close
    end
  end

  def self.update_quotes(symbol)
    cmd = Quote.update_commnd(symbol)
    unless cmd.nil?
      p = IO.popen(cmd)
      puts p.readlines
      p.close
    end
  end

  def self.delete_for_security(s)
    quotes = self.from_security(s, nil, nil)
    if quotes.empty?
      return true
    end
    quotes.each do |q|
      q.destroy
    end
  end

  def self.update_from_split(t)
    s = t.security
    quotes = self.from_security(s, nil, nil)
    if quotes.empty?
      return true
    end

    quotes.delete_if { |q| q.get_date >= t.date }
    quotes.each do |q|
      if (q.adjclose.nil?)
        q.adjclose = q.close
      end

      tmp = q.close/t.shares
      if q.adjclose > tmp
        qdelta =  q.adjclose - tmp
      else
        qdelta =  tmp - q.adjclose
      end
      if qdelta > (q.adjclose * 0.05)
        q.adjclose /= t.shares
        q.save
      end
    end
    QuoteSetting.update_date(s, t.date)
  end

  def self.range_from_security(s, date)
    self.from_company(s.company, date, nil)
  end

  def self.range_from_company(c, date)
    self.from_company(c, date, nil)
  end

  def self.current_from_company(c, fetch=false)
    if fetch
      c.update_historical_quotes
    end
    quotes = self.from_company(c, nil, 1)
    if !quotes.empty?
      return quotes[0]
    else
      return nil
    end
  end

  def self.current_from_security(s, fetch=false)
    current_from_company(s.company, fetch)
  end

  def self.from_security(s, date, limit)
    self.from_company(s.company, date, limit)
  end

  def self.from_company(c, date, limit)
    if c.is_forex
      self.table_name = "forex"
    else
      self.table_name = "quotes"
    end
    if !table_exists?
      return []
    end

    symbol = c.symbol
    if date
      quotes = Quote.find :all,
                          :conditions => [ 'symbol = ? AND date >= ?',
                                           symbol, date.strftime("%Y%m%d") ],
                          :order => 'date DESC'
    elsif limit
      quotes = Quote.find :all, :limit => limit,
                          :conditions => { :symbol => symbol },
                          :order => 'date DESC'
    else
      quotes = Quote.find :all,
                          :conditions => { :symbol => symbol },
                          :order => 'date DESC'
    end
  end

  def get_date
    if date.to_s.size == 10
      Date.civil(date.to_s.slice(0..3).to_i,
	         date.to_s.slice(5..6).to_i,
	         date.to_s.slice(8..9).to_i)
    else
      Date.civil(date.to_s.slice(0..3).to_i,
	         date.to_s.slice(4..5).to_i,
	         date.to_s.slice(6..7).to_i)
    end
  end
end
