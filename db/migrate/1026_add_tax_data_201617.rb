class AddTaxData201617 < ActiveRecord::Migration
  def self.up
    tax_year = TaxYear.new(:year => 2016)
    tax_year.exemption_amount = 4050
    tax_year.standard_deduction_s = 6300
    tax_year.standard_deduction_mfs = 6300
    tax_year.standard_deduction_mfj = 12600
    tax_year.standard_deduction_hh = 9300
    tax_year.tax_income_l1_s = 9275
    tax_year.tax_income_l2_s = 37650
    tax_year.tax_income_l3_s = 91150
    tax_year.tax_income_l4_s = 190150
    tax_year.tax_income_l5_s = 413350
    tax_year.tax_income_l6_s = 415050
    tax_year.tax_income_l1_mfs = 9275
    tax_year.tax_income_l2_mfs = 37650
    tax_year.tax_income_l3_mfs = 75950
    tax_year.tax_income_l4_mfs = 115725
    tax_year.tax_income_l5_mfs = 206675
    tax_year.tax_income_l6_mfs = 233475
    tax_year.tax_income_l1_mfj = 18550
    tax_year.tax_income_l2_mfj = 75300
    tax_year.tax_income_l3_mfj = 151900
    tax_year.tax_income_l4_mfj = 231450
    tax_year.tax_income_l5_mfj = 413350
    tax_year.tax_income_l6_mfj = 466950
    tax_year.tax_income_l1_hh = 13250
    tax_year.tax_income_l2_hh = 50400
    tax_year.tax_income_l3_hh = 130150
    tax_year.tax_income_l4_hh = 210800
    tax_year.tax_income_l5_hh = 413350
    tax_year.tax_income_l6_hh = 441100
    tax_year.save

    tax_year = TaxYear.new(:year => 2017)
    tax_year.exemption_amount = 4050
    tax_year.standard_deduction_s = 6350
    tax_year.standard_deduction_mfs = 6350
    tax_year.standard_deduction_mfj = 12700
    tax_year.standard_deduction_hh = 9350
    tax_year.tax_income_l1_s = 9325
    tax_year.tax_income_l2_s = 37950
    tax_year.tax_income_l3_s = 91900
    tax_year.tax_income_l4_s = 191650
    tax_year.tax_income_l5_s = 416700
    tax_year.tax_income_l6_s = 418400
    tax_year.tax_income_l1_mfs = 9325
    tax_year.tax_income_l2_mfs = 37950
    tax_year.tax_income_l3_mfs = 76550
    tax_year.tax_income_l4_mfs = 116675
    tax_year.tax_income_l5_mfs = 208350
    tax_year.tax_income_l6_mfs = 235350
    tax_year.tax_income_l1_mfj = 18650
    tax_year.tax_income_l2_mfj = 75900
    tax_year.tax_income_l3_mfj = 153100
    tax_year.tax_income_l4_mfj = 233350
    tax_year.tax_income_l5_mfj = 416700
    tax_year.tax_income_l6_mfj = 470700
    tax_year.tax_income_l1_hh = 13350
    tax_year.tax_income_l2_hh = 50800
    tax_year.tax_income_l3_hh = 131200
    tax_year.tax_income_l4_hh = 212500
    tax_year.tax_income_l5_hh = 416700
    tax_year.tax_income_l6_hh = 444550
    tax_year.save
  end

  def self.down
    ty = TaxYear.find_by_year("2016")
    ty.destroy if ty

    ty = TaxYear.find_by_year("2017")
    ty.destroy if ty
  end
end
