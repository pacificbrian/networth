class AddTaxData2012 < ActiveRecord::Migration
  def self.up
    tax_year = TaxYear.new(:year => 2012)
    tax_year.exemption_amount = 3800
    tax_year.standard_deduction_s = 5950
    tax_year.standard_deduction_mfs = 5950
    tax_year.standard_deduction_mfj = 11900
    tax_year.standard_deduction_hh = 8700
    tax_year.tax_income_l1_s = 8700
    tax_year.tax_income_l2_s = 35350
    tax_year.tax_income_l3_s = 85650
    tax_year.tax_income_l4_s = 178650
    tax_year.tax_income_l5_s = 388350
    tax_year.tax_income_l1_mfs = 8700
    tax_year.tax_income_l2_mfs = 35350
    tax_year.tax_income_l3_mfs = 71350
    tax_year.tax_income_l4_mfs = 108725
    tax_year.tax_income_l5_mfs = 194175
    tax_year.tax_income_l1_mfj = 17400
    tax_year.tax_income_l2_mfj = 70700
    tax_year.tax_income_l3_mfj = 142700
    tax_year.tax_income_l4_mfj = 217450
    tax_year.tax_income_l5_mfj = 388350
    tax_year.tax_income_l1_hh = 12400
    tax_year.tax_income_l2_hh = 47350
    tax_year.tax_income_l3_hh = 122300
    tax_year.tax_income_l4_hh = 198050
    tax_year.tax_income_l5_hh = 388350
    tax_year.save
  end

  def self.down
    ty = TaxYear.find_by_year("2012")
    ty.destroy
  end
end
