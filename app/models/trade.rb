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

class Trade < ActiveRecord::Base
  belongs_to :security
  belongs_to :trade_type
  belongs_to :import
  belongs_to :account
  has_many :trade_gains, :foreign_key => "sell_id"
  validates_presence_of :shares
  validates_presence_of :amount
  #validates_presence_of :price

  attr_accessor :security_name
  attr_accessor :symbol
  attr_accessor :cash_flow
  attr_accessor :gain
  attr_accessor :foreign_tax
  attr_accessible :trade_type_id, :date, :symbol, :shares, :price, :amount, :basis, :closed, :tax_year, :foreign_tax

  def tax_item
    if self.income?
      return TaxItem.find(4)
    else
      return TaxItem.find(9)
    end
  end

  def self.sanitize_params(params)
    params[:shares].gsub!(/[^0-9.]/, '\1')
    params[:amount].gsub!(/[^0-9.]/, '\1')
    params[:price].gsub!(/[^0-9.]/, '\1')
    if params[:tax_year].nil?
      params[:tax_year] = params['date(1i)'];
    end
    if params[:price].empty?
      p = params[:amount].to_f / params[:shares].to_f
      params[:price] = p.round(2).to_s
    end
    return params
  end

  def self.requires_parent_update(old, new)
    if (old.trade_type_id != new.trade_type_id)
      return true
    elsif (old.price != new.price)
      return true
    elsif (old.shares != new.shares)
      return true
    elsif (old.amount != new.amount)
      return true
    elsif (old.date != new.date)
      #self.account.delete_saved_balances(old.date)
      #self.account.delete_saved_balances(new.date)
      #return false
      return true
    else
      # allow Basis update, which otherwise parent overwrites
      return false
    end
  end

  def to_cashflow
    tcf = TradeCashFlow.new()
    tcf.trade_id = id
    # TODO - replaced with above?, if remove trade.rb foreign key
    tcf.category_id = id
    tcf.date = date
    tcf.tax_year = tax_year
    tcf.amount = get_out_cash_flow
    tcf.payee_id = security.company.id
    tcf.account_id = account_id
    return tcf
  end

  def split_adjusted_shares
    if (adjusted_shares)
      adjusted_shares
    else
      shares
    end
  end

  def taxable_gain
    if security.account.taxable
      return gain
    end
    return 0
  end

  def amount_ps
    (amount / split_adjusted_shares).round(4)
  end

  def basis_ps
    s = security
    if s.security_basis_type.is_fifo
      amount_ps
    elsif s.security_basis_type.is_avgb
      s.basis_ps
    else
      s.basis_ps
    end
  end

  def basis_remaining
    s = security
    if s.security_basis_type.is_fifo
      if basis
        return (amount - basis)
      end
    end
    return nil
  end

  def get_basis
    b = nil
    if buy?
      b = basis_remaining
    end
    if b.nil?
      b = basis
    end
    return b

    # or avoid nil return?
    if b.nil?
      b = 0
    end
    return b
  end

  def dividend?
    ((self.trade_type_id == 3) ||
    (self.trade_type_id == 5))
  end

  def distribution?
    ((self.trade_type_id == 4) ||
    (self.trade_type_id == 6))
  end

  def income?
    (self.dividend? || self.distribution?)
  end

  def reinvest?
    ((self.trade_type_id == 5) ||
    (self.trade_type_id == 6))
  end

  def buy?
    ((self.trade_type_id == 1) ||
    (self.trade_type_id == 5) ||
    (self.trade_type_id == 6))
  end

  def sell?
    (self.trade_type_id == 2)
  end

  def split?
    (self.trade_type_id == 9)
  end

  def move_shares?
    ((self.trade_type_id == 7) ||
    (self.trade_type_id == 8))
  end
  def shares_in?
    (self.trade_type_id == 7)
  end
  def shares_out?
    (self.trade_type_id == 8)
  end

  def commission
    if (self.buy?)
      @commission = self.amount - (self.price * self.shares)
    elsif (self.sell?)
      @commission = (self.price * self.shares) - self.amount
    end
  end

  def get_out_cash_flow
    if (self.reinvest?)
      a = 0
    elsif (self.income?)
      a = self.amount
    elsif (self.buy?)
      a = -1 * self.amount
    elsif (self.sell?)
      a = self.amount
    else
      a = 0
    end
  end

  def get_reverse_out_cash_flow
    self.get_out_cash_flow * -1
  end

  def get_in_cash_flow
    if (self.buy?)
      value = (self.shares * self.price)
    elsif (self.sell?)
      value = -1 * (self.shares * self.price)
    else
      value = 0
    end
  end

  def get_reverse_in_cash_flow
    s = self.security
    if s.shares.zero?
      -self.get_in_cash_flow
    elsif s.value.zero?
      -self.get_in_cash_flow
    elsif (self.buy?)
      value = -1 * (self.shares * s.price)
    elsif (self.sell?)
      value = (self.shares * s.price)
    else
      value = 0
    end
  end

  def set_gain
    # current trade is a Sell
    # called from Users model when returning user.gains
    if (self.buy? && !self.reinvest?)
      return nil
    end

    t_basis = basis
    if basis.nil?
      t_basis = update_basis_from_gains
    end
    @gain = amount - t_basis
    return gain

    @gain = 0
    trade_gains.each do |tg|
      if tg.basis.nil?
        tg.update_basis
      end
      @gain += tg.amount - tg.basis
    end
    return gain
  end

  def split_ratio
    shares
  end

  def shares_remaining
    remaining = split_adjusted_shares

    sales = TradeGain.find_all_by_buy_id(id)
    sales.each do |tg|
      if (tg.adjusted_shares)
        # set if a split occurred after Sale
        remaining -= tg.adjusted_shares
      else
        remaining -= tg.shares
      end
    end
    remaining
  end

  def delete_gain
    gains = TradeGain.find_all_by_sell_id(id)
    gains.each do |tg|
      buy = Trade.find(tg.buy_id)
      buy.closed = false
      buy.basis -= tg.basis
      buy.save
      tg.destroy
    end
  end

  def record_gain
    # current trade is a Sell
    # add entry to TradeGain
    computed_basis = 0
    shares_sold = shares
    security.active_buy_trades.each do |b|
      tg = TradeGain.new
      shares_remaining = b.shares_remaining
      if shares_remaining > shares_sold
        tg.shares = shares_sold
      else
        tg.shares = shares_remaining
        b.closed = true
      end
      # puts "Shares remaining is: " + shares_remaining
      tg.sell_id = id
      tg.buy_id = b.id

      # TODO - round(4) internally may be problematic....
      _basis = b.basis_ps * tg.shares
      if !(b.basis_remaining.nil?)
        # resolves basis overflow from rounding
        #  see TG[203,58] basis 7266.95 => 7266.96
        if _basis > b.basis_remaining
          _basis = b.basis_remaining
        elsif b.closed
          _basis = b.basis_remaining 
        end
      elsif b.closed
        _basis = b.amount 
      end
      tg.basis = _basis.round(2)

      if (b.basis)
         b.basis += tg.basis
      else
         # only use b.basis if no already posted Sells
         sales = TradeGain.find_all_by_buy_id(b.id)
         if (sales.size.zero?)
            b.basis = tg.basis
         end
      end
      b.save
      tg.save

      computed_basis = computed_basis + _basis
      shares_sold -= tg.shares
      if shares_sold.zero?
        break
      end
    end

    computed_basis = computed_basis.to_f.round(2)
    # Update basis in Sell for use by Gain#index
    self.basis = computed_basis
    self.save
    return computed_basis
  end

  def update_basis_from_gains
    if income?
      self.basis = 0
      self.save
      return 0
    end 

    # current trade is a Sell
    total_basis = 0
    trade_gains.each do |g|
      g_basis = g.basis
      if g.basis.nil?
        g_basis = g.update_basis
      end
      total_basis += g_basis
    end
    self.basis = total_basis
    self.save
    return total_basis
  end

# for new DB fields:
  def set_account_id_from_security
    self.account_id = self.security.account_id
    self.save
  end
end
