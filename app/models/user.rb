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

class User < ActiveRecord::Base
  has_many :user_settings
  has_many :accounts
  has_many :bugs
  has_many :categories
  has_many :payees
  has_many :screeners
  has_many :screener_requests
  has_many :rules
  has_many :taxes, :class_name => 'Tax'
  has_many :tax_users
  has_many :securities, :through => :accounts, :source => :securities
  has_many :r_cash_flows, :through => :accounts, :source => :r_cash_flows
  has_many :cash_flows, :through => :accounts, :source => :cash_flows do
    def by_category(cat_id, range=nil, with_future=nil)
      # XXX need function that removes category with non-zero amount
      #     XXX need to use report_cashflows!!!

    if range
      last = Date.today
      first = last - range.to_i
      if with_future.nil?
        cfs = find :all,
	      	 :conditions => [ 'transfer = ? AND date > ? AND date <= ? AND category_id = ?', false, first, last, cat_id ],
	         :order => 'date ASC'
      else
        cfs = find :all,
	      	 :conditions => [ 'transfer = ? AND date > ? AND category_id = ?', false, first, cat_id ],
	         :order => 'date ASC'
      end
    else
      cfs = find :all, :conditions => { :transfer => false, :category_id => cat_id },
	         :order => 'date ASC'
    end
    cfs.delete_if { |cf| cf.has_splits? }
    cfs.delete_if { |cf| cf.repeat? }
    end
  end

  validates_presence_of     :login
# validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
# validates_length_of       :name, :maximum => 100

# validates_presence_of     :email, :allow_nil => true
# validates_length_of       :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email, :allow_blank => true

  has_secure_password
  attr_accessor :old_password
  attr_accessible :login, :email, :first_name, :last_name
  attr_accessible :old_password, :password, :password_confirmation

  attr_accessor :cashflow_display_limit, :balances_on_refresh, :import_on_refresh
  attr_accessor :account_securities_on_refresh, :quotes_on_refresh
  attr_accessor :balances_on_account_show
  attr_accessible :cashflow_display_limit, :balances_on_refresh, :import_on_refresh
  attr_accessible :account_securities_on_refresh, :quotes_on_refresh
  attr_accessible :balances_on_account_show

  def self.authenticate_current_user(session, user_id)
    current_user = self.find(session[:user_id])
    if current_user.nil? or current_user.id != user_id
      logger.warn "Attempt to lookup non-current User " + user_id.to_s + " (" + (current_user.id if current_user).to_s + ")"
      current_user = nil
    end
    return current_user
  end

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.
  # Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank?
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    # allow empty password
    if password.blank? and u and u.password_digest.nil?
      return u
    end
    u && u.authenticate(password) ? u : nil
  end

  def secured_save(send_code=false)
    self.save
  end

  def secured_update(params)
     no_password_update = params[:old_password].blank? and params[:password].blank?
     if no_password_update
       params.delete("password")
       params.delete("password_confirmation")
       return self.update_attributes(params)
     elsif self.authenticate(params[:old_password])
       return self.update_attributes(params)
     end
     return false
  end

  def settings_by_name(n)
    set = user_settings.find_by_name(n)
    if set
      return set
    else
      set = self.user_settings.find_all_by_name(n)
      set.delete_if { |s| s.user_id != nil }
      if not set.empty?
        return set[0]
      end
    end
    return nil
  end

  def fetch_settings
    setting = settings_by_name("CashFlowDisplayLimit");
    cashflow_display_limit = setting.value if setting
    setting = settings_by_name("BalancesOnRefresh");
    balances_on_refresh = setting.value if setting
    setting = settings_by_name("ImportOnRefresh");
    import_on_refresh = setting.value if setting
    setting = settings_by_name("AccountSecuritiesOnRefresh");
    account_securities_on_refresh = setting.value if setting
    setting = settings_by_name("QuotesOnRefresh");
    quotes_on_refresh = setting.value if setting
    setting = settings_by_name("BalancesOnAccountShow");
    balances_on_account_show = setting.value if setting
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def name
    self.login
  end

  def security_alerts
    alerts = Array.new
    self.securities.each do |s|
      alerts += s.security_alerts
    end
    return alerts
  end

  def ordered_trades(year=nil, type_id=nil, account=nil, use_tax_year=false)
    # need a 3 table join
    year_in = year
    year = year.to_i
    trades = Array.new

    if account
      #parent_array = account.securities
      # TODO - this version (below) handles moved Securities
      parent_array = Array.new
      parent_array.push account 
    else
      parent_array = self.securities
    end

    parent_array.each do |p|
      #a = s.trades.find :all, :conditions => ['date >= ? AND date < ?', Date.ordinal(year, 1), Date.ordinal(year+1, 1) ], :order => 'date DESC'

      if type_id
        if use_tax_year
          a = p.trades.find :all, :conditions => ['tax_year = ? AND trade_type_id = ?', year, type_id ]
        elsif year_in
          a = p.trades.find :all, :conditions => ['date >= ? AND date < ? AND trade_type_id = ?', Date.ordinal(year, 1), Date.ordinal(year+1, 1), type_id ]
        else
          a = p.trades.find :all, :conditions => ['trade_type_id = ?', type_id ]
        end
      else
        if use_tax_year
          a = p.trades.find :all, :conditions => ['tax_year = ?', year ]
        elsif year_in
          a = p.trades.find :all, :conditions => ['date >= ? AND date < ?', Date.ordinal(year, 1), Date.ordinal(year+1, 1) ]
        else
          a = p.trades.find :all
        end
      end
      p_trades = a

      # XXX compare speed
      # trades = trades.find :all, :conditions => ['date >= ? AND date < ?',  Date.ordinal(year, 1), Date.ordinal(year+1, 1) ]
      trades = trades + p_trades
    end
    return trades.sort_by { |t| -t.date.jd }
  end

  def ordered_gains(year, type_id=nil, account=nil, use_tax_year=false)
    trades = ordered_trades(year, type_id, account, use_tax_year)
    trades = trades.select { |t| (t.income? || t.sell?) }
    trades.each do |t|
        t.set_gain
    end
    return trades
  end

  def ordered_gain_cashflows_by_year(year, trade_type_id, account=nil, use_tax_year=false)
    gcf = Array.new
    ordered_gains(year, trade_type_id, account, use_tax_year).each do |t|
      cf = t.to_cashflow
      cf.amount = t.gain
      # caller responsible to delete CFs if wants only non-taxable
      gcf.push cf
    end
    return gcf
  end

  def all_rules
    self.rules + Rule.find(:all, :conditions => { :user_id => nil })
  end

  def user_categories
    Category.find_all_by_user_id(self.id)
  end

  def all_categories(ctype = nil, use_divider = true)
    use_detailed_expenses = true
    divider = Category.find(1)
    categories = []

    if (ctype.nil? || ctype == 1)
      categories = Category.expenses_all(self.id, use_detailed_expenses)
    end

    if (ctype.nil? || ctype == 2)
      if (!categories.empty? && use_divider)
        categories.push(divider)
      end
      categories += Category.income_all(self.id)
    end

    categories = categories.insert(0, divider)
  end

  def get_categories(ctype=nil)
    all_categories(ctype, false)
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

  def current_accounts
    accounts
    accounts.delete_if { |a| (a.hidden || a.watchlist)  }
    return accounts
    #Array(accounts.find :all, :conditions => { :hidden => false, :watchlist => false })
    #Array(accounts.find :all, :conditions => [ '(NOT hidden) AND (NOT watchlist)'])
  end

  def watchlist_accounts
    accounts.find_all_by_watchlist(true)
  end

  def refresh_account_balances
    current_accounts.each do |a|
      a.update_balance
    end
  end

  def refresh(session, full=false)
    if full || !session[:security_values_updated]
      update_security_values(full)
      session[:security_values_updated] = true
      refresh_account_balances
    end
  end

  def new_session(session)
      refresh(session)
  end

  def taxable_gain_by_year(year)
    gain_sum = 0
    ordered_gains(year).each do |t|
      if t.gain
        gain_sum += t.taxable_gain
      end
    end
    return gain_sum
  end

  def balance
    #current_accounts.sum(:balance)
    current_accounts.inject(0) { |sum,a| sum += a.balance_f }
  end

  def by_date_range(end_date, days, flags=nil)
    verbose = false
    name = self.name
    values = Array.new(days, 0)

    self.accounts.each do |a|
      a_values = a.by_date_range(end_date, days, flags)
      v = days - 1
      a_values.reverse.each do |a_value|
        if verbose
          puts a.name + " balance is " + a_value.to_s
        end
        values[v] += a_value
        v -= 1
      end
    end
    return values
  end

  def taxes_by_year(year, type_id=nil, item_id=nil)
    _taxes = Array.new
    if (year)
      d1 = Date.ordinal(year.to_i)
      d2 = Date.ordinal(year.to_i + 1)
      if item_id
      _taxes.concat self.taxes.find :all,
                   :conditions => [ 'year >= ? AND year < ? AND tax_item_id = ?' , d1, d2, item_id ]
      elsif type_id
      _taxes.concat self.taxes.find :all,
                   :conditions => [ 'year >= ? AND year < ? AND tax_type_id = ?' , d1, d2, type_id ]
      else
      _taxes.concat self.taxes.find :all,
                   :conditions => [ 'year >= ? AND year < ?' , d1, d2 ]
      end
    else
      _taxes.concat self.taxes
    end

    return _taxes
  end
end
