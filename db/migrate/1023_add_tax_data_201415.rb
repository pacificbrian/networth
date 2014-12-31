class AddTaxData201415 < ActiveRecord::Migration
  def self.up
    tax_year = TaxYear.new(:year => 2014)
    tax_year.exemption_amount = 3950
    tax_year.standard_deduction_s = 6200
    tax_year.standard_deduction_mfs = 6200
    tax_year.standard_deduction_mfj = 12400
    tax_year.standard_deduction_hh = 9100
    tax_year.tax_income_l1_s = 9075
    tax_year.tax_income_l2_s = 36900
    tax_year.tax_income_l3_s = 89350
    tax_year.tax_income_l4_s = 186350
    tax_year.tax_income_l5_s = 405100
    tax_year.tax_income_l6_s = 406750
    tax_year.tax_income_l1_mfs = 9075
    tax_year.tax_income_l2_mfs = 36900
    tax_year.tax_income_l3_mfs = 74425
    tax_year.tax_income_l4_mfs = 113425
    tax_year.tax_income_l5_mfs = 202550
    tax_year.tax_income_l6_mfs = 228800
    tax_year.tax_income_l1_mfj = 18150
    tax_year.tax_income_l2_mfj = 73800
    tax_year.tax_income_l3_mfj = 148850
    tax_year.tax_income_l4_mfj = 226850
    tax_year.tax_income_l5_mfj = 405100
    tax_year.tax_income_l6_mfj = 457600
    tax_year.tax_income_l1_hh = 12950
    tax_year.tax_income_l2_hh = 49400
    tax_year.tax_income_l3_hh = 127550
    tax_year.tax_income_l4_hh = 206600
    tax_year.tax_income_l5_hh = 405100
    tax_year.tax_income_l6_hh = 432200
    tax_year.save

    tax_year = TaxYear.new(:year => 2015)
    tax_year.exemption_amount = 4000
    tax_year.standard_deduction_s = 6300
    tax_year.standard_deduction_mfs = 6300
    tax_year.standard_deduction_mfj = 12600
    tax_year.standard_deduction_hh = 9250
    tax_year.tax_income_l1_s = 9225
    tax_year.tax_income_l2_s = 37450
    tax_year.tax_income_l3_s = 90750
    tax_year.tax_income_l4_s = 189300
    tax_year.tax_income_l5_s = 411500
    tax_year.tax_income_l6_s = 413200
    tax_year.tax_income_l1_mfs = 9225
    tax_year.tax_income_l2_mfs = 37450
    tax_year.tax_income_l3_mfs = 75600
    tax_year.tax_income_l4_mfs = 115225
    tax_year.tax_income_l5_mfs = 205750
    tax_year.tax_income_l6_mfs = 232425
    tax_year.tax_income_l1_mfj = 18450
    tax_year.tax_income_l2_mfj = 74900
    tax_year.tax_income_l3_mfj = 151200
    tax_year.tax_income_l4_mfj = 230450
    tax_year.tax_income_l5_mfj = 411550
    tax_year.tax_income_l6_mfj = 464850
    tax_year.tax_income_l1_hh = 13150
    tax_year.tax_income_l2_hh = 50200
    tax_year.tax_income_l3_hh = 129600
    tax_year.tax_income_l4_hh = 209850
    tax_year.tax_income_l5_hh = 411500
    tax_year.tax_income_l6_hh = 439000
    tax_year.save
  end

  def self.down
    ty = TaxYear.find_by_year("2014")
    ty.destroy
    ty = TaxYear.find_by_year("2015")
    ty.destroy
  end
end
