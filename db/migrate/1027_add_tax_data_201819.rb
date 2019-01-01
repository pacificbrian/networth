class AddTaxData201819 < ActiveRecord::Migration
  def self.up
    add_column :tax_years, :tax_l1_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l2_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l3_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l4_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l5_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l6_rate, :decimal, :precision => 12, :scale => 4
    add_column :tax_years, :tax_l7_rate, :decimal, :precision => 12, :scale => 4
    TaxYear.reset_column_information

    tax_year = TaxYear.new(:year => 2018)
    tax_year.exemption_amount = 0
    tax_year.standard_deduction_s = 12000
    tax_year.standard_deduction_mfs = 12000
    tax_year.standard_deduction_mfj = 24000
    tax_year.standard_deduction_hh = 18000
    tax_year.tax_income_l1_s = 9525
    tax_year.tax_income_l2_s = 38700
    tax_year.tax_income_l3_s = 82500
    tax_year.tax_income_l4_s = 157500
    tax_year.tax_income_l5_s = 200000
    tax_year.tax_income_l6_s = 500000
    tax_year.tax_income_l1_mfs = 9525
    tax_year.tax_income_l2_mfs = 38700
    tax_year.tax_income_l3_mfs = 82500
    tax_year.tax_income_l4_mfs = 157500
    tax_year.tax_income_l5_mfs = 200000
    tax_year.tax_income_l6_mfs = 300000
    tax_year.tax_income_l1_mfj = 19050
    tax_year.tax_income_l2_mfj = 77400
    tax_year.tax_income_l3_mfj = 165000
    tax_year.tax_income_l4_mfj = 315000
    tax_year.tax_income_l5_mfj = 400000
    tax_year.tax_income_l6_mfj = 600000
    tax_year.tax_income_l1_hh = 13600
    tax_year.tax_income_l2_hh = 51800
    tax_year.tax_income_l3_hh = 82500
    tax_year.tax_income_l4_hh = 157500
    tax_year.tax_income_l5_hh = 200000
    tax_year.tax_income_l6_hh = 500000

    tax_year.tax_l1_rate = 0.10
    tax_year.tax_l2_rate = 0.12
    tax_year.tax_l3_rate = 0.22
    tax_year.tax_l4_rate = 0.24
    tax_year.tax_l5_rate = 0.32
    tax_year.tax_l6_rate = 0.35
    tax_year.tax_l7_rate = 0.37
    tax_year.save

    tax_year = TaxYear.new(:year => 2019)
    tax_year.exemption_amount = 0
    tax_year.standard_deduction_s = 12200
    tax_year.standard_deduction_mfs = 12200
    tax_year.standard_deduction_mfj = 24400
    tax_year.standard_deduction_hh = 18350
    tax_year.tax_income_l1_s = 9700
    tax_year.tax_income_l2_s = 39475
    tax_year.tax_income_l3_s = 84200
    tax_year.tax_income_l4_s = 160725
    tax_year.tax_income_l5_s = 204100
    tax_year.tax_income_l6_s = 510300
    tax_year.tax_income_l1_mfs = 9700
    tax_year.tax_income_l2_mfs = 39475
    tax_year.tax_income_l3_mfs = 84200
    tax_year.tax_income_l4_mfs = 160725
    tax_year.tax_income_l5_mfs = 204100
    tax_year.tax_income_l6_mfs = 306175
    tax_year.tax_income_l1_mfj = 19400
    tax_year.tax_income_l2_mfj = 78950
    tax_year.tax_income_l3_mfj = 168400
    tax_year.tax_income_l4_mfj = 321450
    tax_year.tax_income_l5_mfj = 408200
    tax_year.tax_income_l6_mfj = 612350
    tax_year.tax_income_l1_hh = 13850
    tax_year.tax_income_l2_hh = 52850
    tax_year.tax_income_l3_hh = 84200
    tax_year.tax_income_l4_hh = 160700
    tax_year.tax_income_l5_hh = 204100
    tax_year.tax_income_l6_hh = 510300

    tax_year.tax_l1_rate = 0.10
    tax_year.tax_l2_rate = 0.12
    tax_year.tax_l3_rate = 0.22
    tax_year.tax_l4_rate = 0.24
    tax_year.tax_l5_rate = 0.32
    tax_year.tax_l6_rate = 0.35
    tax_year.tax_l7_rate = 0.37
    tax_year.save
  end

  def self.down
    ty = TaxYear.find_by_year("2018")
    ty.destroy if ty

    ty = TaxYear.find_by_year("2019")
    ty.destroy if ty

    remove_column :tax_years, :tax_l1_rate
    remove_column :tax_years, :tax_l2_rate
    remove_column :tax_years, :tax_l3_rate
    remove_column :tax_years, :tax_l4_rate
    remove_column :tax_years, :tax_l5_rate
    remove_column :tax_years, :tax_l6_rate
    remove_column :tax_years, :tax_l7_rate
  end
end
