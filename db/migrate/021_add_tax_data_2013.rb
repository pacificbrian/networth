class AddTaxData2013 < ActiveRecord::Migration
  def self.up
    add_column :tax_constants, :tax_l7_rate, :decimal, :precision => 12, :scale => 4

    tc = TaxConstant.find(1)
    tc.tax_l7_rate  = 0.396
    tc.save

    add_column :tax_years, :tax_income_l6_s, :integer
    add_column :tax_years, :tax_income_l6_mfs, :integer
    add_column :tax_years, :tax_income_l6_mfj, :integer
    add_column :tax_years, :tax_income_l6_hh, :integer
    TaxYear.reset_column_information

    tax_year = TaxYear.new(:year => 2013)
    tax_year.exemption_amount = 3900
    tax_year.standard_deduction_s = 6100
    tax_year.standard_deduction_mfs = 6100
    tax_year.standard_deduction_mfj = 12200
    tax_year.standard_deduction_hh = 8950
    tax_year.tax_income_l1_s = 8925
    tax_year.tax_income_l2_s = 36250
    tax_year.tax_income_l3_s = 87850
    tax_year.tax_income_l4_s = 183250
    tax_year.tax_income_l5_s = 398350
    tax_year.tax_income_l6_s = 400000
    tax_year.tax_income_l1_mfs = 8925
    tax_year.tax_income_l2_mfs = 36250
    tax_year.tax_income_l3_mfs = 73200
    tax_year.tax_income_l4_mfs = 111525
    tax_year.tax_income_l5_mfs = 199175
    tax_year.tax_income_l6_mfs = 225000
    tax_year.tax_income_l1_mfj = 17850
    tax_year.tax_income_l2_mfj = 72500
    tax_year.tax_income_l3_mfj = 146400
    tax_year.tax_income_l4_mfj = 223050
    tax_year.tax_income_l5_mfj = 398350
    tax_year.tax_income_l6_mfj = 450000
    tax_year.tax_income_l1_hh = 12750
    tax_year.tax_income_l2_hh = 48600
    tax_year.tax_income_l3_hh = 125450
    tax_year.tax_income_l4_hh = 203150
    tax_year.tax_income_l5_hh = 398350
    tax_year.tax_income_l6_hh = 425000
    tax_year.save
  end

  def self.down
    ty = TaxYear.find_by_year("2013")
    ty.destroy

    remove_column :tax_constants, :tax_l7_rate
    remove_column :tax_years, :tax_income_l6_s
    remove_column :tax_years, :tax_income_l6_mfs
    remove_column :tax_years, :tax_income_l6_mfj
    remove_column :tax_years, :tax_income_l6_hh
  end
end
