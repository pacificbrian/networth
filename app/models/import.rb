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

class Import < ActiveRecord::Base
  belongs_to :account
  has_many :cash_flows
  has_many :trades

  def date
    created_on.to_date
  end

  def ofx_transactions_to_cashflows(account, trans, test_date=true)
    cf = Array.new
    last_transnum = account.last_imported_transnum
    last_cf = account.last_cashflow
    do_import = nil

    trans.each do |t|
      c = CashFlow.new
      c.import_id = self.id
      c.account_id = account.id
      c.amount = t.amount
      c.date = t.date_posted
      c.tax_year = c.date.year

      p = t.payee
      if account.payee_length
        limit = account.payee_length - 1
        c.payee_name = p.slice!(0..limit).strip.squeeze(" ")
        p = p.strip.squeeze(" ")
      else
        p = p.strip.squeeze(" ")
        c.payee_name = p
      end
      if !p.empty?
        c.payee_address = p
      end
      c.memo = t.memo

      if t.reference_number
        c.transnum = t.reference_number
      elsif t.corrected_financial_institution_transaction_identifier
        c.transnum = t.financial_institution_transaction_identifier
      elsif t.financial_institution_transaction_identifier
        c.transnum = t.financial_institution_transaction_identifier
      end
      c.needs_review = true

      do_import = true
      if last_transnum
        if c.adj_transnum <= last_transnum
          do_import = false
        end
      end

      if test_date and do_import and last_cf
        if c.date < last_cf.date
          do_import = false
        end
      end

      if do_import
        cf.push c
      end
    end

    return cf.sort_by {|c| (c.transnum.to_i)}
  end

  def send_ofx_request(account, user_name, password, date_range=nil, want_sorted=true)
    trans = Array.new
    inst = account.ofx_institution
    inst.set_client(user_name, password,
		    account.institution.client_uid) if inst
    acc_number = inst.get_account_id(account.ofx_index) if inst

    if acc_number
        acc_has_trans = true
        req = inst.create_request_document_for_cc_statement(
				              acc_number,
                                              date_range, acc_has_trans)
        resp = inst.send(req) if req
        ms = resp.message_sets[1] if resp
        ms_resp = ms.responses[0] if ms
        trans = ms_resp.transactions if ms_resp
        trans = trans.sort_by { |t| t.date_posted } if trans and want_sorted
    end
    return trans
  end

  def delete_cashflows
    self.cash_flows.each do |cf|
      cf.remove_from_account
    end
  end
end
