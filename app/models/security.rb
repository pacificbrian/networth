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

class Security < ActiveRecord::Base
  belongs_to :account
  belongs_to :security_type
  belongs_to :security_basis_type
  belongs_to :company
  has_many :security_alerts
  has_many :trades do
    def ordered_by_date
      find :all, :order => 'date ASC'
    end
    def desc_ordered_by_date
      find :all, :order => 'date DESC'
    end
  end

  attr_accessor :name
  attr_accessor :symbol
  attr_accessible :symbol, :name, :company_id, :security_type_id, :security_basis_type_id, :basis, :value

  def get_class
    if (is_stock?)
      return 0
    else
      return 1
    end
  end

  def get_name
    company.name
  end

  def sell_trades
    trades.delete_if { |t| !t.sell? }
  end

  def trade_gains
    gains = Array.new

    sales = self.sell_trades
    sales.each do |s|
      gains.concat TradeGain.find_all_by_sell_id(s.id)
    end
    return gains
  end

  def is_stock?
    security_type.is_stock?
  end

  def is_fund?
    security_type.is_fund?
  end

  def price
    (value / shares).round(2)
  end

  def basis_ps
    (basis / shares).round(2)
  end

  # for validating self.shares
  def sum_shares
   trades.to_a.inject(0) do |acc, t| 
     if t.sell?
       acc -= t.shares
     else
       acc += t.shares
     end
   end
  end

  ### how to fix basis?
  def add_trade(trade)
    s = self
    update_account = false
    if (trade.buy?)
      #trade.basis = trade.amount
      #trade.save
      s.basis += trade.amount
      s.shares += trade.shares
      s.value += trade.get_in_cash_flow
      update_account = true
    elsif (trade.sell?)
      basis_sold = trade.record_gain
      #s.basis -= (s.basis/s.shares * trade.shares)
      s.basis = s.basis - basis_sold
      s.shares -= trade.shares
      if s.shares.zero?
        s.basis = 0
        s.value = 0
      else
        s.value += trade.get_in_cash_flow
      end
      update_account = true
    elsif (trade.split?)
      s.shares *= trade.shares
      # update open Buy shares
      s.active_buy_trades.each do |t|
        t.adjusted_shares = t.shares * trade.shares
        t.save
        # update partial Sales for Buy trade
        gains = TradeGain.find_all_by_buy_id(t.id)
        gains.each do |g|
          g.adjusted_shares = g.shares * trade.shares
          g.save
        end
      end
      # update past Quote.adjusted_close for Split?
      Quote.update_from_split(trade)

      # TODO
      # flag security to prevent edits prior to Split,
      #  else can't guarantee integrity of data
    elsif (trade.move_shares?)
      if (trade.shares_in?)
        s.shares += trade.shares
      elsif (trade.shares_out?)
        s.shares -= trade.shares
      end
      update_account = false
    else
      update_account = true
    end

    # update security.value from Quotes if present
    svalue_diff = 0
    q = Quote.current_from_security(self,nil)
    if q && q.get_date >= trade.date
      svalue_diff = s.value
      s.value = s.shares * q.close
      svalue_diff = s.value - svalue_diff
    end

    if s.last_quote_update.nil?
      s.last_quote_update = trade.date
    end
    s.save

    if update_account
      s.account.add_trade(trade, svalue_diff)
    end
  end

  def active_trades
    return trades.find :all, :order => 'date ASC',
                       :conditions => [ 'closed != ?', true ]
  end

  def active_buy_trades
    results = active_trades
    results.delete_if { |t| !t.buy? }
    return results
  end

  def reverse_split(trade)
      s = self
      # update open Buy shares
      s.active_buy_trades.each do |t|
        t.adjusted_shares = t.shares / trade.shares
        t.save
        # update partial Sales for Buy trade
        gains = TradeGain.find_all_by_buy_id(t.id)
        gains.each do |g|
          g.adjusted_shares = g.shares / trade.shares
          g.save
        end
      end
      # update Quotes?
      Quote.delete_for_security(s)
  end

  def _sub_trade(trade, undo_split=false)
    # no saving changes! (because called from by_date)
    s = self
    if (trade.buy?)
      s.value += trade.get_reverse_in_cash_flow
      s.shares -= trade.shares
      if s.shares.zero?
        s.basis = 0
        s.value = 0
      else
        s.basis -= trade.amount
      end
    elsif (trade.sell?)
      s.value += trade.get_reverse_in_cash_flow
      s.shares += trade.shares
      # XXX broken
      #s.basis += (s.basis/s.shares * trade.shares)
      #old_basis = s.basis * ((s.basis * s.shares) / trade.shares)
      #s.basis += (old_basis/s.shares * trade.shares)
      if (trade.basis.nil?)
        trade.update_basis_from_gains
      end
      s.basis += trade.basis
    elsif (trade.split?)
      s.shares /= trade.shares
      if (undo_split)
        # this performs 'saves' so only safe from sub_trade caller
        reverse_split(trade)
      end
    end
  end

  def sub_trade(trade, updated_trade=nil)
    self.account.sub_trade(trade)
    self._sub_trade(trade, true)

    if updated_trade.nil?
      if (trade.sell?)
        trade.delete_gain
      end
      self.save
    else
      # in this case, trade.id is nil (from dup)
      trade = updated_trade
      if (trade.sell?)
        trade.delete_gain
      end
      # no save needed
    end
  end

  def update_trade(old_trade, new_trade, forced=nil)
    if (forced or Trade.requires_parent_update(old_trade, new_trade))
      self.sub_trade(old_trade, new_trade)
      self.add_trade(new_trade)
    end
  end

  def by_date(date)
    self.trades.desc_ordered_by_date.each do |t|
      if t.date > date
        self._sub_trade(t)
      end
    end

    # update value from Quotes
    quotes = Quote.range_from_security(self, nil)

    quotes.each do |q|
      if q.get_date <= date
        self.value = self.shares * q.close
        break
      end
    end

    return self
  end

  def by_date_range(first, last)
    values = SecurityValue.from_date_range(self, first, last)
    if values
      return values
    end

    values = Array.new
    quotes = nil

    date = last
    puts date.to_s+" for "+self.company.name
    self.trades.desc_ordered_by_date.each do |t|
      #puts date.to_s+" for "+self.company.name
      if t.date > date
        # reverse trade (in future)
        self._sub_trade(t)
      else
        if self.shares.nonzero?
          if quotes.nil?
            # account for not having weekend quotes
            # XXX why can't this be outside loop?
            quotes = Quote.range_from_security(self, first - 3)
          end

          used_quotes = 0
          # update value from Quotes
          quotes.each do |q|
            if q.get_date <= date
              self.value = self.shares * q.close
              break
            else
              used_quotes += 1
            end
          end
          quotes = quotes.drop(used_quotes)
        end

        #puts date.to_s+" for "+self.company.name+" "+t.date.to_s+" value is "+self.value.to_s+" shares "+self.shares.to_s
        sv = SecurityValue.new
        sv.security_id = self.id
        sv.date = date
        sv.value = self.value
        values.push(sv)

        date = date - 1
        if (date < first)
          break
        end
        redo # repeat for next Date with current Trade
      end
    end

    return values
  end

  def save_values_for_date_range(first, last)
    values = get_date_range(first, last)
    SecurityValue.save_values(self, values)
  end

  def update_value(fetch=false)
    q = Quote.current_from_security(self,fetch)
    if (q)
      quote_date = q.get_date
      if (quote_date != self.last_quote_update)
        # clear old AccountBalances
        if (self.last_quote_update.nil?)
          self.account.delete_saved_balances(nil)
        elsif (quote_date < self.last_quote_update)
          # something strange happened to Quotes db?!
          self.account.delete_saved_balances(quote_date)
        else
          self.account.delete_saved_balances(self.last_quote_update)
        end
        self.last_quote_update = quote_date
      end

      old_value = self.value
      if company.is_forex
        self.value = self.shares * q.close
      else
        self.value = self.shares * q.adjclose
      end
      self.save

      if (old_value != self.value)
puts "updating Security:"+self.company.symbol+" from quotes"
        self.account.balance += (self.value - old_value)
        self.account.save
      end
    end
    return value
  end

  def get_simple_roc
    self.return_simple
  end

  def return_simple
    if (self.basis.zero?)
      return 0
    end
    v = ((self.value - self.basis) / self.basis) * 100
    ((v * 100).round)/100
  end

  def days
    oldest = Date.today
    self.trades.each do |t|
      if t.date < oldest
        oldest = t.date
      end
    end

    (Date.today - oldest).to_i
  end

  def skip_import?
    self.security_basis_type_id == 3
  end

  def debug_shares?
    return false
  end
end
