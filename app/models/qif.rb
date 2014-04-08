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

class Qif < ActiveRecord::Base
  def self.bogus_field
    return 'X'
  end

  def self.payee_field(account)
    qa = account.qif_account
    if qa and qa.payee_in_memo
      return 'M'
    else
      return 'P'
    end
  end

  def self.memo_field(account)
    qa = account.qif_account
    if qa and qa.payee_in_memo
      return Qif.bogus_field
    else
      return 'M'
    end
  end

  def self.to_cashflow(data, offset, account, in_cash_flow)
    content = data[offset..-1]
    if content.nil?
      return [nil, nil]
    end
    output = nil

    if (in_cash_flow)
      cf = in_cash_flow
    else
      cf = CashFlow.new
    end

    content.each do |col|
      offset += 1
      case col.slice!(0..0)
      when 'B'
        cf.amount = nil
      when 'D'
        if !col.nil? && !col.strip.empty?
          #cf.date = Date.parse(col, true)
          cf.date = Date.strptime(col, '%m/%d/%Y')
        end
      when 'N'
        if !col.nil?
          cf.transnum = col.strip
        end
      when Qif.payee_field(account)
        if account.payee_length
          limit = account.payee_length - 1
          cf.payee_name = col.slice!(0..limit).strip.squeeze(" ")
        else
          cf.payee_name = col.strip.squeeze(" ")
        end
        if !col.strip.empty?
          cf.payee_address = col.strip.squeeze(" ")
        end
      when 'A'
        if !col.strip.empty?
          cf.payee_address = col.strip.squeeze(" ")
          #cf.payee_name.slice!(cf.payee_address)
          #cf.payee_name.strip!
        end
      when Qif.memo_field(account)
        if !col.nil?
          cf.memo = col.strip
        end
      when 'T'
        col.delete!(',')
        cf.amount = col.to_f
      when 'L'
        col.strip!
        if col.slice(0..0) == '['
          col.slice!("[")
          col.slice!("]")
          cf.transfer = 1
          cf.payee_name = col
          cf.category_id = 0
        else
          cat = Category.find_by_name(col)
          if cat
            cf.category_id = cat.id
          end
        end
      when 'S'
        split_cf = SplitCashFlow.new
        col.strip!
        if col.slice(0..0) == '['
          col.slice!("[")
          col.slice!("]")
          split_cf.transfer = 1
          split_cf.payee_name = col
          split_cf.category_id = 0
        else
          cat = Category.find_by_name(col)
          if cat
            split_cf.category_id = cat.id
          end
          split_cf.payee_name = cf.payee_name
        end
        split_cf.split = true
        split_cf.date = cf.date
        if !cf.split
          # if cf is top of split, its category is 0
          cf.category_id = 0
        end
        cf.split_cash_flow = split_cf
        output = cf
        break
      when 'E'
        if !col.nil?
          cf.memo = col.strip
        end
      when '$'
        col.delete!(',')
        cf.amount = col.to_f
      when '^'
        if cf.amount && cf.amount.nonzero? then
          output = cf
          break
        else
          cf = CashFlow.new
        end
      else
      end
    end
    return [offset, output]
  end

  def self.to_trade(data, offset, account)
    content = data[offset..-1]
    if content.nil?
      return [nil, nil]
    end
    output = nil

    t = Trade.new
    cf = nil

    content.each do |col|
      offset += 1
      case col.slice!(0..0)
      when 'B'
        t.amount = nil
      when 'N'
        case col.strip
        when "XIn"
          cf = CashFlow.new
          cf.amount = 1
        when "XOut"
          cf = CashFlow.new
          cf.amount = -1
        when "MiscExp"
          cf = CashFlow.new
          cf.amount = -1
        when "Buy"
          t.trade_type_id = 1
        when "Sell"
          t.trade_type_id = 2
        when "IntInc"
          t.trade_type_id = 3
          cf = CashFlow.new
        when "Div"
          t.trade_type_id = 3
          t.price = 0
          t.shares = 0
        when "CGLong"
          t.trade_type_id = 4
          t.price = 0
          t.shares = 0
        when "ReinvInt"
          t.trade_type_id = 5
        when "ReinvDiv"
          t.trade_type_id = 5
        when "ReinvSh"
          t.trade_type_id = 5
        when "ReinvLg"
          t.trade_type_id = 6
        when "BuyX"
          t.trade_type_id = 1
          cf = CashFlow.new
          cf.amount = 1
        when "SellX"
          t.trade_type_id = 2
          cf = CashFlow.new
          cf.amount = -1
        when "DivX"
          t.trade_type_id = 3
          t.price = 0
          t.shares = 0
          cf = CashFlow.new
          cf.amount = -1
        when "CGLongX"
          t.trade_type_id = 4
          t.price = 0
          t.shares = 0
          cf = CashFlow.new
          cf.amount = -1
        when "ShrsOut"
          t.trade_type_id = 8
          t.price = 0
          t.amount = 0
        when "ShrsIn"
          t.trade_type_id = 7
          t.price = 0
          t.amount = 0
        end
      when 'D'
        if !col.nil? && !col.strip.empty?
          #t.date = Date.parse(col, true)
          t.date = Date.strptime(col, '%m/%d/%Y')
        end
      when 'Y'
        t.security_name = col.strip
        if t.security_name.slice(-1..-1) == ")"
          if t.security_name.slice(-6..-6) == "("
            t.security_name.slice!(-6..-1)
          end
        end
        if t.security_name.slice(-1..-1) == "K"
          if t.security_name.slice(-2..-2) == " "
            t.security_name.slice!(-2..-1)
          end
        end
      when 'I'
        col.delete!(',')
        t.price = col
      when 'Q'
        t.shares = col
      when 'T'
        col.delete!(',')
        t.amount = col.to_f
      #when 'O'
      #  t.commission = col.strip
      when 'L'
        col.strip!
        if col.slice(0..0) == '['
          col.slice!("[")
          col.slice!("]")
          cf.transfer = 1
          cf.payee_name = col
          cf.category_id = 0
        else
          cf.category_id = Category.find_by_name(col)
        end
        cf.date = t.date
        cf.amount = cf.amount * t.amount
      when '^'
        if t.amount then
          if cf
            if cf.amount.nil?
              if t.security_name
                #NIntInc to Security
                cf = nil
                t.price = 1
                t.shares = t.amount
              else
                #NIntInc to Cash balance
                cf.date = t.date
                cf.category_id = Category.find_by_name("Interest Income").id
                cf.payee_name = account.name
                cf.amount = t.amount
              end
            end
            t.cash_flow = cf
          end
          output = t
          break
        else
          t = Trade.new
          cf = nil
        end
      else
      end
    end
    return [offset, output]
  end
end
