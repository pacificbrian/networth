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
      else
        c.payee_name = p.strip.squeeze(" ")
      end
      if !p.strip.empty?
        c.payee_address = p.strip.squeeze(" ")
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

  def send_ofx_request(account, user_name, password, date_range=nil)
    trans = Array.new
    ofx_name = account.institution.name
    institution = OFX::FinancialInstitution.get_institution(ofx_name)
    return trans if institution.nil? or not account.credit?
    
    institution.set_client(user_name, password)
    acc_number = institution.get_account_id

    if acc_number
        acc_has_trans = true
        req = institution.create_request_document_for_cc_statement(
				              acc_number,
                                              date_range, acc_has_trans)
        resp = institution.send(req) if req
        trans = resp.message_sets[1].responses[0].transactions if resp
    end
    return trans
  end
end
