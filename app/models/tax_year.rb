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

class TaxYear < ActiveRecord::Base
  attr_accessible :year

  def standard_deduction_from_filing_status(status)
    standard_deduction_mfj
  end
  def tax_income_l1_from_filing_status(status)
    tax_income_l1_mfj
  end
  def tax_income_l2_from_filing_status(status)
    tax_income_l2_mfj
  end
  def tax_income_l3_from_filing_status(status)
    tax_income_l3_mfj
  end
  def tax_income_l4_from_filing_status(status)
    tax_income_l4_mfj
  end
  def tax_income_l5_from_filing_status(status)
    tax_income_l5_mfj
  end
  def tax_income_l6_from_filing_status(status)
    tax_income_l6_mfj
  end
end
