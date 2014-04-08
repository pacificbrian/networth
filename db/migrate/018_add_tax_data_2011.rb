class AddTaxData2011 < ActiveRecord::Migration
  def self.up
    tax_year = TaxYear.new(:year => 2011)
    tax_year.exemption_amount = 3700
    tax_year.standard_deduction_s = 5800
    tax_year.standard_deduction_mfs = 5800
    tax_year.standard_deduction_mfj = 11600
    tax_year.standard_deduction_hh = 8500
    tax_year.tax_income_l1_s = 8500
    tax_year.tax_income_l2_s = 34500
    tax_year.tax_income_l3_s = 83600
    tax_year.tax_income_l4_s = 174400
    tax_year.tax_income_l5_s = 379150
    tax_year.tax_income_l1_mfs = 8500
    tax_year.tax_income_l2_mfs = 34500
    tax_year.tax_income_l3_mfs = 69675
    tax_year.tax_income_l4_mfs = 106150
    tax_year.tax_income_l5_mfs = 189575
    tax_year.tax_income_l1_mfj = 17000
    tax_year.tax_income_l2_mfj = 69000
    tax_year.tax_income_l3_mfj = 139350
    tax_year.tax_income_l4_mfj = 212300
    tax_year.tax_income_l5_mfj = 379150
    tax_year.tax_income_l1_hh = 12150
    tax_year.tax_income_l2_hh = 46250
    tax_year.tax_income_l3_hh = 119400
    tax_year.tax_income_l4_hh = 193350
    tax_year.tax_income_l5_hh = 379150
    tax_year.save

    add_column :cash_flows, :tax_year, :integer
    CashFlow.all.each do |c|
      c.tax_year = c.date.year
      c.save
    end

    add_column :trades, :tax_year, :integer
    Trade.all.each do |t|
      t.tax_year = t.date.year
      t.save
    end
  end
  def self.down
    ty = TaxYear.find_by_year("2011")
    ty.destroy

    remove_column :cash_flows, :tax_year
    remove_column :trades, :tax_year
  end
end
