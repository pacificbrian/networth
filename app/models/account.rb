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

require 'csv'
class Account < ActiveRecord::Base
  belongs_to :user
  belongs_to :account_type
  belongs_to :currency_type
  belongs_to :institution
  has_one :ofx_account
  has_one :qif_account
  has_many :imports
  has_many :imported_cash_flows, :through => :imports, :source => :cash_flows
  has_many :split_cash_flows
  has_many :payees, :through => :cash_flows
  has_many :security_alerts, :through => :securities, :source => :security_alerts
  has_many :account_balances do
    def by_date_range(last, days)
      first = last - (days - 1)
      #return AccountBalance.from_date_range(self, first, last)
      find :all, :order => 'date ASC',
           :conditions => [ 'date <= ? AND date >= ?', last, first]
    end

    def find_last
      ab = find :all, :order => 'date DESC'
      if ab.empty?
        return nil
      else
        return ab[0]
      end
    end

    def find_last_by_year(year)
      first = Date.new(year)
      last = Date.new(year+1) - 1
      ab = find :all, :order => 'date DESC',
                :conditions => [ 'date <= ? AND date >= ?', last, first]
      if ab.empty?
        return nil
      else
        return ab[0]
      end
    end
  end
  has_many :r_cash_flows do
    def ordered_by_date
      find :all, :order => 'date DESC'
    end
  end
  has_many :cash_flows do
    def ordered_by_date(range=nil, inc_transfers=true)
      if range.nil?
        cfs = find :all, :conditions => { :type => nil }
      else
        last = Date.today
        first = Date.today - range
# TODO - include future cash_flows? (omit last test)
        cfs = find :all,
		   :conditions => [ 'date >= ? AND date <= ?', first, last],
 		   :order => 'date DESC'
        cfs.delete_if { |cf| !cf.base_class? }
      end

      if not inc_transfers
        cfs.delete_if { |cf| cf.transfer }
      end
      return cfs
    end
    def with_report_amount
      #cfs = find :all, :conditions => { :type => nil }
      cfs = find :all, :conditions => { :transfer => false }, :order => 'date DESC'
      cfs.delete_if { |cf| 
        (cf.report_amount.nil? || cf.report_amount.zero?)
      }
      return cfs
    end
    def transfers_by_year(year)
      if year.nil?
        return Array.new
      end
      first = Date.new(year)
      last = Date.new(year + 1) - 1
      cfs = find :all,
	      	 :conditions => [ 'transfer == ? AND date >= ? AND date <= ?', true, first, last ],
	         :order => 'date DESC'
      cfs.delete_if { |cf| cf.repeat? }
    end
    def transfers
      cfs = find :all, :conditions => { :transfer => true }, :order => 'date DESC'
      cfs.delete_if { |cf| cf.repeat? }
    end

    # returns cash_flows for use in Charts (only those with Categories (not split owner, not repeat))
    def by_range(last, range, cat_id=nil)
      # XXX need function that removes category with non-zero amount
      # XXX should use report_cashflows?!

     if range
      #last = Date.today
      first = last - range.to_i
      if cat_id
      cfs = find :all,
	      	 :conditions => [ 'transfer == ? AND date > ? AND date <= ? AND category_id == ?', false, first, last, cat_id ],
	         :order => 'date ASC'
      else
      cfs = find :all,
	      	 :conditions => [ 'transfer == ? AND date > ? AND date <= ?', false, first, last ],
	         :order => 'date ASC'
      end
     else
      if cat_id
      cfs = find :all, :conditions => [ 'transfer == ? AND category_id == ?', false, cat_id ],
	         :order => 'date ASC'
      else
      cfs = find :all, :conditions => { :transfer => false },
	         :order => 'date ASC'
      end
     end
     cfs.delete_if { |cf| cf.has_splits? }
     cfs.delete_if { |cf| cf.repeat? }
     return cfs
    end
  end
  has_many :securities
  has_many :trades
  validates_presence_of :name
  attr_accessible :account_type_id, :currency_type_id, :taxable, :hidden, :watchlist
  attr_accessible :name, :number, :routing, :payee_length, :cash_balance, :balance

  #payee_length:  MC=23,  AMEX=20

  def self.sanitize_params(params)
    if params[:balance]
      negate = (params[:balance].index("-") == 0)
      params[:balance].gsub!(/[^0-9.]/, '\1')
      if negate
        params[:balance] = "-".concat(params[:balance])
      end
    end
    if params[:cash_balance]
      negate = (params[:cash_balance].index("-") == 0)
      params[:cash_balance].gsub!(/[^0-9.]/, '\1')
      if negate
        params[:cash_balance] = "-".concat(params[:cash_balance])
      end
    end
    return params
  end

  def date_opened
    c = cash_flows.ordered_by_date
    if c.empty?
      Date.today
    else
      c[0].date
    end
  end

  def transfer_sum
    cfs = cash_flows.transfers
    cfs.inject(0) {|total, c| total + c.amount }
  end

  def cashflows_by_category(ctype, range=nil, fill_all=false)
    cfs = cash_flows.by_range(Date.today, range)
    category_cfs = Array.new

    categories = get_categories(ctype)
    categories.each do |c|
      match = cfs.select {|cf| cf.category_id == c.id}
      # TODO: do we need fill_all=false to skip match.empty?
      category_cfs.push(match)
    end

    return category_cfs
  end

  def ordered_r_cash_flows
    self.r_cash_flows.ordered_by_date
  end

  def ordered_trades(year=nil, type_id=nil)
    if !year.nil?
      return user.ordered_trades(year, type_id, self)
    end

    if type_id
      _trades = trades.find_by_trade_type_id(type_id)
    else
      _trades = trades
    end
    _trades.sort_by { |t| -t.date.jd }
  end

  def cleanse_by_payee(name)
    payee = Payee.find_by_name(name)
    if payee
      cfs = self.cash_flows.find(:all,
              :conditions => {:type => nil, :payee_id => payee.id})
      cfs.each do |cf|
        cf.purge
      end
    end
  end

  def active_securities
    securities.find :all, :conditions => ['shares > 0']
  end

  def update_security_values(fetch=false)
    as_list = active_securities
    as_list.each do |s|
      #puts "updating security " + s.id.to_s
      s.update_value(fetch)
    end
    as_list
  end

  def add_trade_cash_flows(trade)
    if !trade.foreign_tax.nil? && !trade.foreign_tax.to_i.zero?
puts "adding ForeignTax cashflow"
      t_cf = CashFlow.new
      t_cf = self.cash_flows.new
      t_cf.date = trade.date
      t_cf.payee_name = trade.security.company.symbol
      t_cf.amount = -trade.foreign_tax.to_i
      t_cf.category_id = 57

      cf = self.cash_flows.new
      cf.update_from(t_cf)
    end
  end

  def update_balance
    self.balance = cash_balance + total_securities_value
    self.save
  end

  def refresh(session, full=false)
    RCashFlow.process_by_account(self)
    if investment? && (full || !session[:security_values_updated])
      update_security_values(full)
      update_balance
    end
  end

  def investment?
    #(self.account_type_id == AccountType.find_by_name('Investment').id)
    account_type.investment?
  end

  def deposit?
    #(self.account_type_id == AccountType.find_by_name('Checking/Deposit').id)
    account_type.deposit?
  end

  def credit?
    #(self.account_type_id == AccountType.find_by_name('Credit Card').id)
    account_type.credit?
  end

  def loan?
    #(self.account_type_id == AccountType.find_by_name('Loan').id)
    account_type.loan?
  end

  def health?
    #(self.account_type_id == AccountType.find_by_name('Health Care').id)
    account_type.health?
  end

  def asset?
    #(self.account_type_id == AccountType.find_by_name('Asset').id)
    account_type.asset?
  end

  def get_icon_path
    account_type.get_icon_path
  end

  def _find_security(symbol, type)
    security = self.securities.find_by_company_id(symbol.id)
    unless security
      security = self.securities.create(:company_id => symbol.id,
                                        :security_type_id => type)
    end
    return security
  end

  def find_security_by_symbol(sym, type=1)
    symbol = Company.find_by_symbol(sym)
    unless symbol
      symbol = Company.create_from_symbol(sym)
    end
    security = _find_security(symbol, type)
  end

  def find_security_by_name(name, type=1)
    symbol = Company.find_by_name(name)
    unless symbol
      symbol = Company.create_from_name(name)
    end
    security = _find_security(symbol, type)
  end

  def next_transnum
    return nil
  end

  def get_transnum_shift
    if transnum_shift
      return transnum_shift
    elsif payee_length == 20
      return 1
    else
      return 0
    end
  end

  def cashflow_limit
    user.cashflow_limit
  end

  def last_cashflow
    cfs = cash_flows.ordered_by_date(60, false)
    cfs.delete_if { |cf| cf.from_repeat? }
    if cfs
      return cfs[0]
    else
      return nil
    end
  end

  def last_imported_transnum
    cf = imported_cash_flows
    if cf
      scf = cf.sort_by {|c| -(c.adj_transnum.to_i)}
      t = scf[0].adj_transnum
    else
      t = nil
    end
    return t
  end

  def adjust_cash(v)
    self.cash_balance += v
    self.balance += v
  end

  def add_trade(trade, adj_balance=nil)
    @portfolio = nil
    self.delete_saved_balances(trade.date)
    self.adjust_cash(trade.get_out_cash_flow)
    if adj_balance
      self.balance += trade.get_in_cash_flow + adj_balance
    else
      self.balance += trade.get_in_cash_flow
    end
    self.save
  end

  def sub_trade(trade)
    @portfolio = nil
    self.delete_saved_balances(trade.date)
    self.adjust_cash(trade.get_reverse_out_cash_flow)
    self.balance += trade.get_reverse_in_cash_flow
    self.save
  end

  def add_cash_flow(cf)
    if (!cf.split)
      self.delete_saved_balances(cf.date)
      self.adjust_cash(cf.amount)
      self.save
    end
    if (cf.transfer)
      add_normalized_balance(cf.amount)
    end
  end

  def sub_cash_flow(cf)
    if cf.transfer
      undo_normalize = cf.amount
    else
      undo_normalize = nil
    end

    if (!cf.split)
      self.delete_saved_balances(cf.date, undo_normalize)
      self.adjust_cash(-cf.amount)
      self.save
    elsif (cf.transfer)
      self.delete_saved_balances(cf.date, undo_normalize)
    end
  end

  def total_cash_flows
    #cash_flows.inject(0) {|total, c| total + c.amount }
    #cash_flows.sum(:amount) || BigDecimal("0.0")
    cash_flows.sum(:amount).round(2)
  end

  def total_securities_value
    securities.sum(:value).round(2)
  end

  def purge
    a = self
    a.cash_flows.each do |cf|
      cf.purge
    end
    a.destroy
  end

  def ordered_cash_flows_by_year(year, normalize=false, limit=nil)
    if (year)
      start_date = Date.new(year)
      end_date = Date.new(year+1) - 1
      cfs = CashFlow.find :all, 
	                  :conditions => [ 'date >= ? AND date <= ? AND account_id == ?', start_date, end_date, self.id ]
      # REF: mods 179 and 181 touched (broke?) this, now simplifed to use base_class
      cfs.delete_if { |cf| !cf.base_class? }
    else
      cfs = CashFlow.find :all, :conditions => { :type => nil, :account_id => self.id }
    end

    if cfs.empty?
      return cfs
    end

    # make cashflows for Trade transactions for display in ledger
    if (self.investment?)
    self.trades.each do |t|
      t_amount = t.get_out_cash_flow
      if (year.nil?)
        use_tcf = true
      elsif (year && t.date >= start_date && t.date <= end_date)
        use_tcf = true
      else
        use_tcf = false
      end

      if (!t_amount.zero? && use_tcf)
        tcf = t.to_cashflow()
        cfs.push(tcf)
      end
    end
    end

    scfs = cfs.sort_by { |cf| -cf.date.jd }

    if limit.nil? and year.nil? and cashflow_limit
      limit = cashflow_limit
    end
    if limit
      scfs = scfs.take(limit)
    end


    # TODO - needed for ordered_cash_flows callers (charts)
    calculate_balance = true
    if (!calculate_balance)
      return scfs
    end

    # moved to Account#show
    next_balance = nil
    scfs.each do |cf|
      if next_balance
        cf.balance = next_balance
      else
        cf.balance = self.cash_balance
      end
      cf.normalized_balance = cf.balance
      next_balance = cf.balance - cf.amount
    end

    if (normalize)
      scfs.each_index do |i|
        cf = scfs[i]
        if cf.transfer
          # apply transfer.amount to ALL previous cash_flow balances
          scfs.each_index do |j|
            normal_cf = scfs[j]
            if (j > i)
              normal_cf.normalized_balance += cf.amount
            end
          end
        end
      end
      #scfs.delete_if { |cf| cf.transfer }
    end

    return scfs
  end

  def ordered_cash_flows(normalize=false, limit=nil)
    ordered_cash_flows_by_year(nil, normalize, limit)
  end

  def by_date(date)
    total = 0
    self.ordered_cash_flows.each do |cf|
      if cf.date <= date
        total = cf.balance
        break
      end
    end
    self.securities.each do |s|
      total = total + s.by_date(date).value
    end
    self.balance = total
  end

  def add_normalized_balance(amount)
    # TODO - disable until performance is fixed here...
puts "skipping normalized_Balance updates..."
    return

    # TODO can this be done in an SQL operation?
    balances = AccountBalance.find_all_by_account_id(id)
    balances.each do |ab|
      #ab.increment!(:normalized_balance, amount)
      ab.normalized_balance += amount
      ab.save
    end
  end

  def delete_saved_balances(from=nil, normalize_amount=nil)
    # delete AccountBalances with Date including/after "from"
    #AccountBalance.delete_all(:account_id, id)
    #AccountBalance.destroy_all(["account_id = ? AND date > ?", id, from])
    if from.nil?
      num = AccountBalance.delete_all(["account_id = ?", id])
    else
      num = AccountBalance.delete_all(["account_id = ? AND date >= ?", id, from])
    end

    if ((num > 0) && normalize_amount)
      add_normalized_balance(-normalize_amount)
    end
    return num
  end

  def write_saved_balances(clear_saved=nil)
    b = Array.new
    if (clear_saved)
      delete_saved_balances
    end
    days_to_open = (Date.today - self.date_opened) + 1
    if days_to_open > 0
       b = by_date_range((Date.today), days_to_open, nil, false)
    end
    return b
  end

  def update_saved_balances(start_date)
    last = Date.today
    by_date_range(last, (last - start_date) + 1)
  end

  def by_date_range(last, days, flags=nil, use_saved_values=true, validate_saved_values=true)
    values = Array.new
    saved_values = Array.new
    first = last - (days - 1)
    days_remaining = days
    normalize = flags

    if normalize
puts "used normalized Account balances...."
    end

   if use_saved_values
    if validate_saved_values
      if self.account_balances.size > ((Date.today - self.date_opened) + 1)
puts "AccountBalances is corrupt with too many days!"
        self.write_saved_balances(true)
      end
    end

    saved_values = self.account_balances.by_date_range(last, days)

    if saved_values.empty?
puts "AccountBalances had ALL days missing , 0 of " + days.to_s + " days"
      last_in_db  = self.account_balances.find_last
      if last_in_db.nil?
        # call recursively?,  populate DB then continue....
        self.write_saved_balances
      else
        #self.write_saved_balances
        # or more optimal, fetch last value and update since then 
        update_days = (last - last_in_db.date) + 1
        # TODO - can be negative if (viewing old year?)?
puts "AccountBalances had ALL days missing, testing prior saved values exist or not.. using " + update_days.to_s + " days"
        # trying to fill in missing dates, incl. prior to requested [last - days]
        saved_values = self.by_date_range(last, update_days)
      end
      saved_values = self.account_balances.by_date_range(last, days)
    end

    if saved_values.empty?
      # suggests the entire range is not yet recorded
      days_remaining = days
      before_account_days = 0
    else
      oldest_in_range = saved_values[0].date
      before_account_days = oldest_in_range - first
      if (before_account_days < 0)
        # ERROR in by_date_range
        before_account_days = 0
      end

      # if before_account_days can test if date valid and refresh AccountBalances
      if before_account_days > 0 and (first >= self.date_opened)
puts "AccountBalances is corrupt " + before_account_days.to_s + " lost days, repairing....!"
        self.write_saved_balances(true)
        saved_values = self.account_balances.by_date_range(last, days)
        oldest_in_range = saved_values[0].date
        before_account_days = oldest_in_range - first
      end
      days_remaining = days - saved_values.size - before_account_days
    end
puts "AccountBalances had " + before_account_days.to_s + " days defunct, " + saved_values.size.to_s + " of " + days.to_s + " days"

    if days_remaining <= 0
      # just return saved_values[].balance
      saved_values.each do |v|
        if normalize
          values.push(v.normalized_balance)
        else
          values.push(v.balance)
        end
      end
puts "returning all balances from AccountBalance"
      return values
    end
   end # if use_saved_values

puts "computing balances for Account for days_remaining " + days_remaining.to_s

    sv_array = Array.new
    first = last - (days_remaining - 1)

    i = 0
    self.securities.each do |s|
      sv_array.push(s.by_date_range(first, last))
      puts "security "+self.securities[i].company.name+" cf size is "+sv_array[i].size.to_s
      i += 1
    end
    puts "securities in Account is "+sv_array.size.to_s

    date = last
    ocfs = self.ordered_cash_flows(true)
    ocfs.each do |cf|
      # look at only most recent cash_flow wrt. each date
      if cf.date <= date
        total = 0
        i = 0
        sv_array.each do |svalues|
          #puts "date is "date.to_s+" for security "+self.securities[i].company.name+", total = "+(cf.balance+total).to_s
          if ! svalues.empty?
            sv = svalues.delete_at(0)
            total += sv.value
            #puts "date is "+date.to_s+" size = "+svalues.size.to_s + ", value = " + sv.value.to_s + ", total = " + (cf.balance+total).to_s
          end
          i = i + 1
        end

        # update AccountBalances cache
        if cf.balance
          #ab = self.account_balances.find_by_date(date)
          ab = self.account_balances.new
          ab.cash_balance = cf.balance
          ab.balance = cf.balance + total
          ab.normalized_balance = cf.normalized_balance + total
          ab.date = date
          ab.save
        end

        if normalize
          values.insert(0, cf.normalized_balance + total)
        else
          values.insert(0, cf.balance + total)
        end
        date = date - 1
        if (date < first)
          break
        end

        # continue processing current CF as long as not newer CF than date
        redo
      end
    end

    # prepend saved_values[].balance
    saved_values.reverse.each do |v|
      if normalize
        values.insert(0, v.normalized_balance)
      else
        values.insert(0, v.balance)
      end
    end
    return values
  end

  def portfolio
    if @portfolio
      return @portfolio
    end

    basis = 0
    v = 0
    self.securities.each do |s|
      if s.shares.nonzero?
        basis = basis + s.basis
        v = v + s.value
      end
    end

    @portfolio = Security.new
    @portfolio.basis = basis
    @portfolio.value = v
    return @portfolio
  end

  def self.from_params(params)
    if (params[:account_id])
      Account.find(params[:account_id])
    else
      return nil
    end
  end

  def balance_f
    balance.to_f
  end

  def get_categories(ctype=nil)
    cats = user.all_categories(ctype, false)
    cats.each do |c|
      c.account_id = id
    end
    cats
  end

  def import_csv(file)
    account = self
    parsed_file = CSV::Reader.parse(file)
    parsed_file.shift

    n = 0
    if (account.investment?)
      import = nil
    else
      import = account.imports.create

      parsed_file.each  do |row|
        c = account.cash_flows.new
        c.date = row[0]
        c.payee_name = row[2]
        if (account.deposit?)
          c.transnum = row[1]
          c.memo = row[5]
          if (row[3])
            c.amount = row[3]
          else
            c.amount = row[4]
          end
        else
          c.amount = row[4]
        end
        c.payee_id = c.get_payee_id(account.user.payees)
        c.category_id = c.payee.category_id
        c.import_id = import.id
        c.needs_review = true
        if c.update_from(c)
          n = n + 1
          GC.start if n%50 == 0
        end
      end
    end

    return import
  end

  def import_qif(f, skip_test=true)
    account = self
    import = account.imports.create
    u_payees = account.user.payees

    data = f.read.split("\n")
    count = 0
    n = 0
    if (account.investment?)
      rc = Qif.to_trade(data, count, account)
      count = rc[0]
      t = rc[1]

      while t
        t.account_id = account.id
        security = nil
        if t.security_name
          security = account.find_security_by_name(t.security_name, 1)
          t.security_id = security.id
          if security.skip_import?
            security = nil
          end
          t.import_id = import.id
          t.needs_review = true
        end

        if t.cash_flow
          cash_flow = CashFlow.new()
          # XXX instead set cash_flow.account_id from t.cash_flow.id?
          cash_flow.account_id = account.id
          t.import_id = import.id
          t.needs_review = true
          cash_flow.update_from(t.cash_flow)
        end

        if security && t.save
          security.add_trade(t)
          n = n + 1
          GC.start if n%50 == 0
        end
        rc = Qif.to_trade(data, count, account)
        count = rc[0]
        t = rc[1]
      end
    else
      rc = Qif.to_cashflow(data, count, account, nil)
      count = rc[0]
      c = rc[1]
      while c
        if skip_test
          p_id = c.get_payee_id(u_payees)
          if p_id and Payee.find(p_id).skip_on_import
            rc = Qif.to_cashflow(data, count, account, nil)
            count = rc[0]
            c = rc[1]
            next
          end
        end

        if (c.split)
          cash_flow = SplitCashFlow.new()
        else
          cash_flow = CashFlow.new()
          c.needs_review = true
        end
        # XXX instead set cash_flow.account_id from c.id?
        cash_flow.account_id = account.id
        c.import_id = import.id

        if cash_flow.update_from(c)
          n = n + 1
          GC.start if n%50 == 0
        end

        if c.split_cash_flow && !c.split
          c.split_cash_flow.split_from = cash_flow.id
        elsif c.split_cash_flow && c.split
          c.split_cash_flow.split_from = c.split_from
        end

        rc = Qif.to_cashflow(data, count, account, c.split_cash_flow)
        count = rc[0]
        c = rc[1]
      end
    end

    return import
  end

  def import_ofx(trans, skip_test=true)
    account = self
    n = 0
    if true
      import = Import.new
      cfs = import.ofx_transactions_to_cashflows(account, trans)
      if skip_test
        u_payees = account.user.payees
        cfs.delete_if { |cf| Payee.find(cf.get_payee_id(u_payees)).skip_on_import }
        if cfs.size == 0
          return nil
        end
      end

      import = account.imports.create
      cfs.each do |c|
        if (c.split)
          cash_flow = SplitCashFlow.new()
        else
          cash_flow = CashFlow.new()
        end
        cash_flow.account_id = account.id
        c.needs_review = true
        c.import_id = import.id
        if cash_flow.update_from(c)
          n = n + 1
          GC.start if n%50 == 0
        end
      end
    end

    return import
  end

  def ofx_login
    if ofx_account
      return ofx_account.login
    end
  end

  def ofx_password
    if ofx_account
      return ofx_account.password
    end
  end

  def import_ofx_with_cred(user_name=nil, passwd=nil)
    i = Import.new
    if user_name.nil?
      user_name = self.ofx_login
    end
    if passwd.nil?
      passwd = self.ofx_password
    end
    if user_name.nil? or passwd.nil?
      return i
    end
    trans = i.send_ofx_request(self, user_name, passwd, nil)
    import_ofx(trans)
  end

  def show_transfers_sum?
    return true if investment? or (deposit? and name.match('avings'))
  end
end
