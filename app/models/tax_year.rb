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

  def tc
    return TaxConstant.find(1)
  end

  def standard_deduction_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    standard_deduction_s
    when 'MFJ'
    standard_deduction_mfj
    when 'MFS'
    standard_deduction_mfs
    when 'HH'
    standard_deduction_hh
    end
  end

  def tax_income_l1_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l1_s
    when 'MFJ'
    tax_income_l1_mfj
    when 'MFS'
    tax_income_l1_mfs
    when 'HH'
    tax_income_l1_hh
    end
  end

  def tax_income_l2_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l2_s
    when 'MFJ'
    tax_income_l2_mfj
    when 'MFS'
    tax_income_l2_mfs
    when 'HH'
    tax_income_l2_hh
    end
  end

  def tax_income_l3_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l3_s
    when 'MFJ'
    tax_income_l3_mfj
    when 'MFS'
    tax_income_l3_mfs
    when 'HH'
    tax_income_l3_hh
    end
  end

  def tax_income_l4_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l4_s
    when 'MFJ'
    tax_income_l4_mfj
    when 'MFS'
    tax_income_l4_mfs
    when 'HH'
    tax_income_l4_hh
    end
  end

  def tax_income_l5_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l5_s
    when 'MFJ'
    tax_income_l5_mfj
    when 'MFS'
    tax_income_l5_mfs
    when 'HH'
    tax_income_l5_hh
    end
  end

  def tax_income_l6_from_filing_status(status)
    tfs = TaxFilingStatus.find(status)
    case tfs.label
    when 'S'
    tax_income_l6_s
    when 'MFJ'
    tax_income_l6_mfj
    when 'MFS'
    tax_income_l6_mfs
    when 'HH'
    tax_income_l6_hh
    end
  end

  def tax_l1_rate
    return super || tc.tax_l1_rate
  end

  def tax_l2_rate
    return super || tc.tax_l2_rate
  end

  def tax_l3_rate
    return super || tc.tax_l3_rate
  end

  def tax_l4_rate
    return super || tc.tax_l4_rate
  end

  def tax_l5_rate
    return super || tc.tax_l5_rate
  end

  def tax_l6_rate
    return super || tc.tax_l6_rate
  end

  def tax_l7_rate
    return super || tc.tax_l7_rate
  end

  def capgain_rate
    return super || tc.capgain_rate
  end
end
