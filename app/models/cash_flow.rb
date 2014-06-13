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

class CashFlow < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  belongs_to :import
  belongs_to :payee
  belongs_to :repeat_interval
  # TODO: no longer need?
  belongs_to :trade, :foreign_key => "category_id"
  has_many :split_cash_flows, :foreign_key => "split_from" do
    def ordered_by_date
      find :all, :order => 'date DESC'
    end
  end

  validates_presence_of :date
  validates_presence_of :category_id
  validates_presence_of :payee_id
  validates_numericality_of :amount

  attr_accessor :balance
  attr_accessor :normalized_balance
  attr_accessible :account_id, :cash_flow_type_id, :date, :transnum, :payee_name, :amount, :category_id, :memo
  attr_accessible :split_from, :split, :import_id, :tax_year
  attr_accessible :payee_id, :transfer, :report_amount

  def self.sanitize_params(params)
    if params[:amount]
      params[:amount].gsub!(/[^0-9.]/, '\1')
      # remove any commas or periods that preceed 3 digits
      #params[:amount].gsub!(/[\.\,](\d{3})/, '\1')
    end
    return params
  end

  def self.params_to_cf(params)
    new_cf = CashFlow.new
    return new_cf.params_to_cf(params)
  end

  def self.fetch(_id)
    cash_flow = CashFlow.find(_id)
    if cash_flow
      return cash_flow.set_defaults
    end
  end

  def amount_to_f
    amount.to_f
  end

  def set_default_report_amount
    if self.transfer
      self.report_amount = 0
    elsif self.repeat?
      self.report_amount = 0
    elsif self.has_splits?
      self.report_amount = 0
      # XXX
    else
      self.report_amount = self.amount
    end
    self.save
  end

  def parent
    # split is problematic (private method? errors)
    if self[:split]
      CashFlow.find_by_id(self.split_from)
    else
      return nil
    end
  end

  def repeat?
    if self.class == RCashFlow
      return true
    elsif self.parent && self.parent.class == RCashFlow
      return true
    else
      return false
    end
  end

  def base_class?
    self.class != RCashFlow && self.class != SplitCashFlow
  end

  def debit?
    t = self.cash_flow_type_id.to_i - 1;
    ((t % 2) == 0)
    #CashFlowType.debit?(self.cash_flow_type_id)
  end

  def transfer?
    t = self.cash_flow_type_id.to_i - 1;
    ((t % 4) > 1)
    #CashFlowType.transfer?(self.cash_flow_type_id)
  end

  def from_repeat?
    base_class? && repeat_interval_id
  end

  def num_split
    # split is problematic (private method? errors)
    if (!(self[:split]))
      return self.split_from
    else
      return 0
    end
  end

  def has_splits?
    # OR: (cf.split_from != 0 && !cf.split)
    if (self.num_split.zero?)
      return false
    else
      return true
    end
  end

  def is_split_member?(cf)
    # split is problematic (private method? errors)
    if (cf[:split]) && (cf.split_from == self.id)
      return true
    else
      return false
    end
  end

  def is_editable?
    not (has_splits? || transfer || trade?)
  end

  def get_split_cash_flows
    self.account.cash_flows.find(:all, :conditions => { :split => true, :split_from => self.id }, :order => 'date DESC')
  end

  def update_repeat_interval_id(r_id)
    self.split_cash_flows.each do |scf|
      scf.repeat_interval_id = r_id
      scf.save
    end
    self.repeat_interval_id = r_id
    self.save
  end

  def update_account_id(account_id)
    self.split_cash_flows.each do |scf|
      scf.account_id = account_id
      scf.save
    end
    self.account_id = account_id
    self.save
  end

  def calculate_pi(r)
    l = nil
    p_cf = nil
    i_cf = nil
    balance = nil

    #if !self.split? && self.has_splits?
      self.get_split_cash_flows.each do |scf|
        if scf.transfer
          l = Account.find(scf.payee_id)
          balance = l.balance
          p_cf = scf
        else
          i_cf = scf
        end
      end
    #end
    if i_cf.nil?
      i_cf = self
      l = self.account
      days = 30
      balances = l.by_date_range(date, days)
      balance = (balances.sum / days).round(2)
    end

    if l && i_cf
      i = (balance * (r/100)) / 12
      i_cf.amount = i.round(2)
      puts "balance of "+balance.to_s+" recalc I is "+i_cf.amount.to_s
      i_cf.save

      if p_cf
        p_cf.amount = (amount - i_cf.amount)
        puts "recalc P is "+(amount - i_cf.amount).to_s
        p_cf.save
      end
    end
  end

  def advance_date
    ri = self.repeat_interval
    rit = ri.repeat_interval_type
    if (rit.days.zero?)
      self.purge
      return false
    elsif (rit.days > 15)
      d = self.date.>>(rit.days/30)
    elsif (rit.days < 15)
      d = self.date.+(rit.days)
    else
      # FIXME
      d = self.date.+(rit.days)
    end

    self.date = d
    self.tax_year = d.year
    self.save
    return true
  end

  def record_single_cash_flow(parent_id=nil)
    rcf = self
    #puts "Looking at"
    #puts rcf.inspect
    saved_splitf = rcf.split_from
puts "processing Scheduled CF for Payee " + rcf.get_payee_name

    if (rcf[:split])
      cf = SplitCashFlow.new
      rcf.split_from = parent_id
    else
      # if have interest rate, recalculate amounts
      if !repeat_interval.rate.nil?
        self.calculate_pi(repeat_interval.rate)
      end

      cf = CashFlow.new
      unless rcf.transnum.nil?
        rcf.transnum = rcf.account.next_transnum
      end
      rcf.split_from = 0

      # mark for Review
      cf.needs_review = true
    end
    cf.account_id = rcf.account_id
    cf.repeat_interval_id = self.id
    rcf.payee_name = rcf.get_payee_name
    cf.update_from(rcf, automated=true)

    rcf.split_from = saved_splitf
    rcf.split_cash_flows.each do |scf|
      scf.repeat_interval_id = rcf.repeat_interval_id
      scf.record_single_cash_flow(cf.id)
    end

    if (!rcf.repeat_interval.repeats_left.nil? && parent_id.nil? &&
        rcf.repeat_interval.repeats_left.nonzero?)
      rcf.repeat_interval.repeats_left -= 1
      rcf.repeat_interval.save
    end

    if !rcf.advance_date || parent_id
      rcf = nil
    end

    return true
  end

  def repeat_valid?
    if ((Date.today >= date) && 
	(repeat_interval.repeats_left.nil? || 
	 repeat_interval.repeats_left > 0))
      return true
    else
      return false
    end
  end

  def record_cash_flow
    while (repeat_valid?)
      record_single_cash_flow
    end
  end

  def attach_transfer?
    # maybe not possible? at one point considered having
    # RCashFlow splits also of type RCashFlow, which this covers
    #  XXX source of transfer BUG.....
    if self.repeat?
      return false
    end
    return true
  end

  def prune_update_attributes(attrs)
    attrs.delete("created_at")
    attrs.delete("updated_at")
    attrs.delete("type")
    attrs.delete("needs_review")
    attrs.delete("repeat_interval_id")
    attrs.delete("id")
    return attrs
  end

  def params_to_cf(params)
    params = prune_update_attributes(params)
    params = CashFlow.sanitize_params(params)

    self.assign_attributes(params)
    new_cf = self

    if (new_cf.amount.nil?)
      return nil
    end

    if (new_cf.debit?)
      new_cf.amount *= -1
    end

    if (new_cf.transfer?)
      new_cf.transfer = 1
    else
      new_cf.transfer = 0
    end

    if new_cf.tax_year.nil?
      new_cf.tax_year = new_cf.date.year
    end

    return new_cf
  end

  def trade_id=(x)
    @trade_id = x
  end
  def trade_id
    @trade_id
  end

  def trade?
    self.trade_id
  end

  def security
    if trade?
      t = Trade.find(self.trade_id)
      s = t.security
    else
      s = nil
    end
    return s
  end

  def split_cash_flow=(x)
    @split_cash_flow = x
  end
  def split_cash_flow
    @split_cash_flow
  end

  def cash_flow_type_id=(x)
    @cash_flow_type_id = x
  end
  def cash_flow_type_id
    @cash_flow_type_id
  end

  def payee_name=(x)
    @payee_name = x
  end
  def payee_name
    @payee_name
  end

  def payee_address=(x)
    @payee_address = x
  end
  def payee_address
    @payee_address
  end

  def set_defaults
    cash_flow = self

    if (cash_flow.amount < 0)
      cash_flow.cash_flow_type_id = 1
      cash_flow.amount *= -1
    else
      cash_flow.cash_flow_type_id = 2
    end

    if (cash_flow.transfer)
      cash_flow.cash_flow_type_id += 2
    end

    cash_flow.payee_name = cash_flow.get_payee_name
    return cash_flow
  end

  def get_transfer_account_id(accounts, name)
    a = accounts.find_by_name(name)
    if a
      return a.id
    else
      a = accounts.create(:name => name)
      return a.id
    end
  end

  def get_payee_id(payees)
    name = self.payee_name
    p = payees.find_by_name(name)
    if (p)
      pid = p.id
    else
      p = payees.create(:name => name, :address => self.payee_address)
      pid = p.id
    end
  end

  def get_payee_name
    if self.trade?
      Company.find(self.payee_id).name
    elsif self.transfer
      Account.find(self.payee_id).name
    elsif self.payee_id.nil?
      return ""
    else
      self.payee.name
    end
  end

  def get_split_payee_name
    n = get_payee_name
    if self[:split]
      n = "=> " + n
    end
    return n
  end

  def get_cat_name
    if self.trade?
      if self.trade
        self.trade.trade_type.name
      else
        'Trade'
      end
    elsif self.transfer
      'Transfer'
    elsif self.has_splits?
      'Split'
    elsif self.category_id.nil?
      "--"
    elsif self.category_id < 2
      "--"
    else
      self.category.name
    end
  end

  def adj_transnum
    if self.transnum
      return self.transnum[account.get_transnum_shift..-1]
    else
      return 0
    end
  end


  def short_transnum
    if self.transnum
      if self.transnum.length < 5
        return self.transnum
      end
    end
  end

  def update_transfer(t_cf, prune_balances=true)
    cash_flow = self
    if cash_flow.payee_id.zero?
      return false
    end
    t_cf.date = cash_flow.date
    t_cf.tax_year = cash_flow.tax_year
    t_cf.payee_id = cash_flow.account.id
    t_cf.amount = cash_flow.amount * -1
    t_cf.report_amount = 0
    t_cf.account_id = cash_flow.payee_id
    t_cf.category_id = cash_flow.id
    t_cf.transfer = 1
    t_cf.save

    #BUG
    #t_cf.account.add_cash_flow(t_cf)
    Account.find(cash_flow.payee_id).add_cash_flow(t_cf, prune_balances)
    return true
  end

  def purge
    cf = self
    if cf.has_splits?
      cf.get_split_cash_flows.each do |scf|
        scf.destroy
      end
    end
    # XXX test if repeat? work properly here.....
    if !(cf[:split]) && cf.repeat?
      cf.repeat_interval.destroy
    end
    cf.destroy
  end

  def remove_from_account
    cf = self
    if (cf.transfer && cf.category_id.nonzero?)
      old_transfer = CashFlow.find(cf.category_id)
      old_transfer.transfer = 0
      old_transfer.account.sub_cash_flow(old_transfer)
      old_transfer.purge
    end
    cf.account.sub_cash_flow(cf)
    cf.purge
  end

  def update_from(new_cf, automated=false)
    prune_balances = (not automated)
    new_cf.account_id = self.account_id

    current_user = self.account.user
    #current_user = User.find(session[:user_id])

    if (self[:split])
      old_split = true
      # needed because we update from CashFlow w/o these set
      new_cf.split_from = self.split_from
      new_cf.split = true
    end

    if (new_cf[:split])
      parent_cf = CashFlow.find(new_cf.split_from)
      if (!new_cf.transfer)
        new_cf.payee_name = parent_cf.payee.name
      end
      new_cf.date = parent_cf.date
      new_cf.tax_year = parent_cf.tax_year
    end

    pname = new_cf.payee_name
    if (!pname)
      return nil
    end

    saved_cat = nil
    if (new_cf.transfer)
      new_cf.payee_id = get_transfer_account_id(current_user.accounts, pname)
      new_cf.category_id = 0
      new_cf.report_amount = 0
    else
      new_cf.payee_id = new_cf.get_payee_id(current_user.payees)
      if new_cf.repeat?
        new_cf.report_amount = 0
      else
        new_cf.report_amount = new_cf.amount
      end
      if new_cf.category_id.nil?
        new_cf.category_id = new_cf.payee.category_id
      elsif self.id.nil?
        saved_cat = new_cf.category_id
      end
    end

    if (self.transfer && self.category_id.nonzero?)
      old_transfer = CashFlow.find(self.category_id)
    end

    new_attrs = prune_update_attributes(new_cf.attributes)
    if self.update_attributes(new_attrs)
      cash_flow = self

      if (old_transfer)
        # TODO - can we optimize normalized_balance actions?
        old_transfer.account.sub_cash_flow(old_transfer)
      end

      if cash_flow.transfer
        if (old_transfer)
          # TODO - can we optimize normalized_balance actions?
          t_cf = old_transfer
        elsif cash_flow.attach_transfer?
          t_cf = CashFlow.new()
        end
      elsif old_transfer
        old_transfer.destroy
      end

      if cash_flow.has_splits?
        scf_amount_total = 0
        # update DATE,PAYEE,INTERVAL in splits
        # XXX why get_split_cash_flows??
        cash_flow.get_split_cash_flows.each do |scf|
          scf.date = cash_flow.date
          scf.tax_year = cash_flow.tax_year
          # update Repeat CF info (it's pending, not a posted cashflow)
          if cash_flow.repeat?
            scf.repeat_interval_id = cash_flow.repeat_interval_id
          end
          if !scf.transfer
            scf.payee_id = cash_flow.payee_id
          end
          scf.save
          scf_amount_total += scf.amount
        end
        if !cash_flow.repeat?
          cash_flow.report_amount -= scf_amount_total
          cash_flow.save
        end
      elsif cash_flow[:split]
        parent_cf = cash_flow.parent
        if !old_split
          parent_cf.split_from = parent_cf.split_from + 1
        end
        # update parent to adjust for this split
        # XXX test if repeat? work properly here.....
        #if !parent_cf.repeat?
        #  parent_cf.report_amount = parent_cf.amount
        #  parent_cf.report_amount -= parent_cf.get_split_cash_flows.sum(:amount)
        #end
        #else
        # XXX - move into initial report_amount assignment
        # DONE if repeat? works.....
        #  cash_flow.report_amount = 0
        #  cash_flow.save
        #end
        parent_cf.save
      end

      if t_cf
        if !cash_flow.update_transfer(t_cf, prune_balances)
          t_cf.destroy
          if cash_flow.category_id
            cash_flow.category_id = nil
            cash_flow.save
          end
        else
          cash_flow.category_id = t_cf.id
          cash_flow.save
        end
      else
        if saved_cat
          cash_flow.payee.category_id = saved_cat
          cash_flow.payee.save
        end
        if !cash_flow.repeat?
          cash_flow.payee.set_use_count
        end
      end

      if cash_flow.base_class?
        cash_flow.account.add_cash_flow(cash_flow, prune_balances)
        # TODO - missing normalized balance action?
      end

      return true
    else
      return false
    end
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

  def by_date_range(first, last)
    values = Array.new
    sv_array = Array.new

    self.securities.each do |s|
      sv_array.push(s.by_date_range(first, last))
      #puts "for security "+self.securities[i].company.name+" size is "+sv_array[i].size.to_s
    end

    date = last
    self.ordered_cash_flows.each do |cf|
      if cf.date <= date
        total = cf.balance

        #i = 0
        sv_array.each do |svalues|
          #puts"for security "+self.securities[i].company.name
          #puts "date is "+date.to_s+" size is "+svalues.size.to_s
          if ! svalues.empty?
            sv = svalues.delete_at(0)
            total = total + sv.value
          end
          #i = i + 1
        end

        values.insert(0, total)
        date = date - 1
        if (date < first)
          break
        end
        redo
      end
    end

    return values
  end


  #
  # for 'fixing' DB
  #

  def self.destroy_split_from(id)
    if (CashFlow.find_by_id(id))
      return nil
    end
    splits = CashFlow.find_all_by_split_from(id)
    splits.each do |s|
      s.destroy
    end
    return splits
  end

  def self.orphan_cash_flows(do_destroy=false)
    orphans = Array.new
    splits = CashFlow.find_all_by_split(true)
    splits.each do |s|
      if (!CashFlow.find_by_id(s.split_from))
        orphans.push s
      end
    end

    if (do_destroy)
      orphans.each do |o|
        o.destroy
      end
    end
    return orphans
  end

  def self.invalid_transfer_cash_flows(include_dups=false)
    cfs = Array.new
    cf_transfers = CashFlow.find_all_by_transfer(true)
    cf_transfers.each do |t|
      if (t.category_id.zero? && !t.repeat?)
        cfs.push t
      end
    end

    if (include_dups)
      cf_transfers.each do |t1|
        match_count = 0
        last_match = nil
        cf_transfers.each do |t2|
          if t2.category_id == t1.id
            match_count += 1
            if match_count > 1
              cfs.push t2
              if match_count == 2
                cfs.push CashFlow.find(last_match)
              end
            end
            last_match = t2.id
          end
        end
      end
    end

    return cfs
  end

  def self.months_between_defunct(a, b)
    if (a > b)
      date1 = b
      date2 = a
    else
      date1 = a
      date2 = b
    end

    months = 0
    first_in_year = date1

    # add months from years past
    if date1.year != date2.year
        months += 12 * (date2.year - date1.year)
        months -= (date1.month - 1)
        first_in_year = date2.at_beginning_of_year
    end

    # add months in current year
    months += (date2.month - first_in_year.month)

#puts months.to_s + " months inbetween " + a.to_s + " and " + b.to_s
    return months
  end

  def self.months_between(a, b)
    if (a > b)
      date1 = b
      date2 = a
    else
      date1 = a
      date2 = b
    end

    months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
#puts months.to_s + " months inbetween " + a.to_s + " and " + b.to_s
    return months
  end

  def self.by_month(datapoints, credit)
    monthly = Array.new
    data = Array.new
    datapoint_max = 0
    datapoint_min = 0

    if (credit)
      debit = false
    else
      debit = true
    end

    num_datapoints = datapoints.size
    if num_datapoints > 0
      high_idx = 0
      s_datapoints = datapoints.sort_by { |d| d.date }
      date_first_month = s_datapoints[0].date.at_beginning_of_month
      date_last_month = s_datapoints[num_datapoints - 1].date.at_beginning_of_month
      num_months = self.months_between(date_first_month, date_last_month)
      datapoints_by_month = Array.new(num_months + 1, 0)

      datapoints.each do |d|
        idx = self.months_between(date_first_month, d.date)
        value = d.amount
        if debit
          value *= -1
        end
        datapoints_by_month[idx] += value

        if idx > high_idx
          high_idx = idx
        end

        if datapoints_by_month[idx] > datapoint_max
         datapoint_max = datapoints_by_month[idx]
        end

        if datapoints_by_month[idx] < datapoint_min
         datapoint_min = datapoints_by_month[idx]
        end
      end

      0.upto(high_idx) do |i|
        month = date_first_month >> i
        pair = Array.new
        pair << Category.monthly_date(month)
        pair << datapoints_by_month[i].to_f
        data << pair
      end
    end

    monthly << data
    monthly << datapoint_max
    monthly << datapoint_min
    return monthly
  end
end
