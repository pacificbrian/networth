class CreateTaxes < ActiveRecord::Migration
  def self.up
    create_table :taxes do |t|
      t.date :year
      t.decimal :amount, :precision => 16, :scale => 4
      t.integer :user_id
      t.integer :tax_region_id
      t.integer :tax_item_id
      t.integer :tax_type_id
      t.string :memo
    end

    create_table :tax_cash_flows do |t|
      t.integer :tax_id
      t.integer :cash_flow_id
    end

    create_table :tax_filing_status do |t|
      t.string :name
      t.string :label, :limit => 20
    end
    TaxFilingStatus.create(:name => 'Single', :label => 'S')
    TaxFilingStatus.create(:name => 'Married Filing Jointly', :label => 'MFJ')
    TaxFilingStatus.create(:name => 'Married Filing Separately', :label => 'MFS')
    TaxFilingStatus.create(:name => 'Head of Household', :label => 'H')

    create_table :tax_regions do |t|
      t.string :name
    end
    TaxRegion.create(:name => 'Federal')
    TaxRegion.create(:name => 'State')
    TaxRegion.create(:name => 'State - CA')
    TaxRegion.create(:name => 'State - MN')

    create_table :tax_types do |t|
      t.string :name
    end
    TaxType.create(:name => 'Income')
    TaxType.create(:name => 'Income_Capital_Gain')
    TaxType.create(:name => 'Deductions for AGI')
    TaxType.create(:name => 'Deductions from AGI')
    TaxType.create(:name => 'Itemized Deductions')
    TaxType.create(:name => 'Tax')
    TaxType.create(:name => 'Tax Credits')
    TaxType.create(:name => 'Tax Payments')

    create_table :tax_categories do |t|
      t.integer :tax_item_id
      t.integer :category_id
      t.integer :trade_type_id
    end

    create_table :tax_items do |t|
      t.string :name
      t.string :type
      t.integer :tax_type_id
      t.integer :tax_category_id
    end
    TaxIncomeItem.create(:name => 'Wages')
    TaxIncomeItem.create(:name => 'Interest Taxable')
    TaxIncomeItem.create(:name => 'Interest Exempt')
    TaxIncomeItem.create(:name => 'Ordinary Dividends')
    TaxIncomeItem.create(:name => 'Qualified Dividends')
    TaxIncomeItem.create(:name => 'Refunds')
    TaxIncomeItem.create(:name => 'Alimony')
    TaxIncomeItem.create(:name => 'Business')
    TaxIncomeItem.create(:name => 'Capital Gain')
    TaxIncomeItem.create(:name => 'Other Gain')
    TaxIncomeItem.create(:name => 'IRA Distributions')
    TaxIncomeItem.create(:name => 'IRA Distributions Taxable')
    TaxIncomeItem.create(:name => 'Pension Annuities')
    TaxIncomeItem.create(:name => 'Pension Annuities Taxable')
    TaxIncomeItem.create(:name => 'Supplemental Schedule E')
    TaxIncomeItem.create(:name => 'Farm')
    TaxIncomeItem.create(:name => 'Unemployment')
    TaxIncomeItem.create(:name => 'Social Security')
    TaxIncomeItem.create(:name => 'Social Security Taxable')
    TaxIncomeItem.create(:name => 'Other Income')

    TaxIncomeCapitalGainItem.create(:name => 'Short Asset Sales')
    TaxIncomeCapitalGainItem.create(:name => 'Short Asset Gain')
    TaxIncomeCapitalGainItem.create(:name => 'Short Other')
    TaxIncomeCapitalGainItem.create(:name => 'Short Carryover')
    TaxIncomeCapitalGainItem.create(:name => 'Short K1')
    TaxIncomeCapitalGainItem.create(:name => 'Long Asset Sales')
    TaxIncomeCapitalGainItem.create(:name => 'Long Asset Gain')
    TaxIncomeCapitalGainItem.create(:name => 'Long Other')
    TaxIncomeCapitalGainItem.create(:name => 'Long Carryover')
    TaxIncomeCapitalGainItem.create(:name => 'Long K1')
    TaxIncomeCapitalGainItem.create(:name => 'Long Distributions')
    TaxIncomeCapitalGainItem.create(:name => 'Collectibles')
    TaxIncomeCapitalGainItem.create(:name => 'Unrecaptured')
    TaxIncomeCapitalGainItem.create(:name => 'Short Carryforward')
    TaxIncomeCapitalGainItem.create(:name => 'Long Carryforward')

    TaxDeductionForAGIItem.create(:name => 'Archer MSA')
    TaxDeductionForAGIItem.create(:name => 'Business 2106')
    TaxDeductionForAGIItem.create(:name => 'HSA Deduction')
    TaxDeductionForAGIItem.create(:name => 'Moving Expenses')
    TaxDeductionForAGIItem.create(:name => 'Self-Employment Tax')
    TaxDeductionForAGIItem.create(:name => 'SE Qualified Retirement')
    TaxDeductionForAGIItem.create(:name => 'SE Health Insurance')
    TaxDeductionForAGIItem.create(:name => 'Early Withdrawal Penalty')
    TaxDeductionForAGIItem.create(:name => 'Alimony')
    TaxDeductionForAGIItem.create(:name => 'IRA Deduction')
    TaxDeductionForAGIItem.create(:name => 'Student Loan Interest')
    TaxDeductionForAGIItem.create(:name => 'Educator Expenses')
    TaxDeductionForAGIItem.create(:name => 'Tutition Fees')
    TaxDeductionForAGIItem.create(:name => 'Lost Jury Pay')
    TaxDeductionForAGIItem.create(:name => 'Domestic 8903')

    TaxDeductionFromAGIItem.create(:name => 'Standard Deduction')
    TaxDeductionFromAGIItem.create(:name => 'Itemized Deductions')
    TaxDeductionFromAGIItem.create(:name => 'Exemption Amount')

    TaxDeductionItemizedItem.create(:name => 'Medical Dental')
    TaxDeductionItemizedItem.create(:name => 'Medical Dental Allowed')
    TaxDeductionItemizedItem.create(:name => 'State Local Income Taxes')
    TaxDeductionItemizedItem.create(:name => 'Real Estate Taxes')
    TaxDeductionItemizedItem.create(:name => 'Personal Property Taxes')
    TaxDeductionItemizedItem.create(:name => 'Other Taxes')
    TaxDeductionItemizedItem.create(:name => 'Mortgage Interest Points')
    TaxDeductionItemizedItem.create(:name => 'Mortgage Interest Paid')
    TaxDeductionItemizedItem.create(:name => 'Qualified Mortgage Insurance Premiums')
    TaxDeductionItemizedItem.create(:name => 'Mortgage Points Other')
    TaxDeductionItemizedItem.create(:name => 'Investment Interest')
    TaxDeductionItemizedItem.create(:name => 'Gifts Cash Check')
    TaxDeductionItemizedItem.create(:name => 'Gifts Other')
    TaxDeductionItemizedItem.create(:name => 'Gifts Carryover')
    TaxDeductionItemizedItem.create(:name => 'Casualty Theft Losses')
    TaxDeductionItemizedItem.create(:name => 'Casualty Theft Losses Allowed')
    TaxDeductionItemizedItem.create(:name => 'Unreimbursed Employee Expenses')
    TaxDeductionItemizedItem.create(:name => 'Tax Preparation Fees')
    TaxDeductionItemizedItem.create(:name => 'Investment Other Expenses')
    TaxDeductionItemizedItem.create(:name => 'Total Job Misc Allowed')
    TaxDeductionItemizedItem.create(:name => 'Other Misc Gambling')
    TaxDeductionItemizedItem.create(:name => 'Other Misc Casualty Theft Losses')
    TaxDeductionItemizedItem.create(:name => 'Other Misc All Other')

    TaxTaxItem.create(:name => 'Income Tax')
    TaxTaxItem.create(:name => 'Other Tax')
    TaxTaxItem.create(:name => 'AMT')
    TaxTaxItem.create(:name => 'SE')
    TaxTaxItem.create(:name => 'Unreported Tips')
    TaxTaxItem.create(:name => 'Additional Retirement')
    TaxTaxItem.create(:name => 'Advance Earned Income')
    TaxTaxItem.create(:name => 'Household Employment')

    TaxCreditItem.create(:name => 'Foreign Tax')
    TaxCreditItem.create(:name => 'Dependent Care')
    TaxCreditItem.create(:name => 'Elderly Care')
    TaxCreditItem.create(:name => 'Education')
    TaxCreditItem.create(:name => 'Retirement Contributions')
    TaxCreditItem.create(:name => 'Residental Energy')
    TaxCreditItem.create(:name => 'Child Tax')
    TaxCreditItem.create(:name => 'Other')

    TaxPaymentItem.create(:name => 'Federal Tax Withheld')
    TaxPaymentItem.create(:name => 'Tax Prepayments')
    TaxPaymentItem.create(:name => 'Earned Income Credit')
    TaxPaymentItem.create(:name => 'Combat Pay')
    TaxPaymentItem.create(:name => 'Excess Social Security')
    TaxPaymentItem.create(:name => 'Child Tax Credit')
    TaxPaymentItem.create(:name => 'Filing Extension')
    TaxPaymentItem.create(:name => 'Telephone Excise')
    TaxPaymentItem.create(:name => 'Minimum Tax')
    TaxPaymentItem.create(:name => 'Other Payments')
    TaxPaymentItem.create(:name => 'Homebuyer Credit')
    TaxPaymentItem.create(:name => 'Stimulus')
  end

  def self.down
    drop_table :taxes
    drop_table :tax_cash_flows
    drop_table :tax_categories
    drop_table :tax_filing_status
    drop_table :tax_regions
    drop_table :tax_types
    drop_table :tax_items
  end
end
