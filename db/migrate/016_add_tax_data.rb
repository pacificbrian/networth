class AddTaxData < ActiveRecord::Migration
  def self.up
    tc = TaxConstant.new
    tc.interest_allowed = 1500
    tc.dividend_allowed = 1500
    tc.standard_dependent_base = 850
    tc.standard_dependent_extra = 300
    tc.exemption_hi_agi_s = 122500
    tc.exemption_hi_agi_mfs = 61250
    tc.exemption_hi_agi_mfj = 122500
    tc.exemption_hi_agi_hh = 122500
    tc.exemption_mid_amount_s = 2500
    tc.exemption_mid_amount_mfs = 1250
    tc.exemption_mid_amount_mfj = 2500
    tc.exemption_mid_amount_hh = 2500
    tc.exemption_mid_rate = 0.02
    tc.capgain_rate = 0.15
    tc.capgain_collectible_rate = 0.28
    tc.capgain_unrecaptured_rate = 0.25
    tc.caploss_limit_s = 3000
    tc.caploss_limit_mfs = 1500
    tc.caploss_limit_mfj = 3000
    tc.caploss_limit_hh = 3000
    tc.amt_mid_limit_s = 112500
    tc.amt_mid_limit_mfs = 75000
    tc.amt_mid_limit_mfj = 150000
    tc.amt_mid_limit_hh = 112500
    tc.amt_high_limit_s = 175000
    tc.amt_high_limit_mfs = 87500
    tc.amt_high_limit_mfj = 175000
    tc.amt_high_limit_hh = 175000
    tc.item_medical_rate = 0.075
    tc.item_jobmisc_rate = 0.02
    tc.item_casualty_theft_min = 100
    tc.item_casualty_theft_rate = 0.10
    tc.item_limit_rate = 0.80
    tc.item_limit_upper_rate = 0.03
    tc.amt_medical_rate = 0.025
    tc.amt_low_rate = 0.25
    tc.amt_mid_rate = 0.26
    tc.tax_table_10 = 5
    tc.tax_table_25 = 25
    tc.tax_table_50 = 3000
    tc.tax_table_max = 100000
    tc.tax_l1_rate = 0.10
    tc.tax_l2_rate = 0.15
    tc.tax_l3_rate = 0.25
    tc.tax_l4_rate = 0.28
    tc.tax_l5_rate = 0.33
    tc.tax_l6_rate = 0.35
    tc.save

    tax_year = TaxYear.new(:year => 2007)
    tax_year.standard_deduction_s = 5350
    tax_year.standard_deduction_mfs = 5350
    tax_year.standard_deduction_mfj = 10700
    tax_year.standard_deduction_hh = 7850
    tax_year.standard_deduction_extra_s = 1300
    tax_year.standard_deduction_extra_mfs = 1050
    tax_year.standard_deduction_extra_mfj = 1050
    tax_year.standard_deduction_extra_hh = 1300
    tax_year.exemption_amount = 3400
    tax_year.exemption_hi_amount = 1133
    tax_year.exemption_mid_rate = 1.5
    tax_year.exemption_agi_s = 156400
    tax_year.exemption_agi_mfs = 117300
    tax_year.exemption_agi_mfj = 234600
    tax_year.exemption_agi_hh = 195500
    tax_year.item_limit_s = 156400
    tax_year.item_limit_mfs = 78200
    tax_year.item_limit_mfj = 156400
    tax_year.item_limit_hh = 156400
    tax_year.item_limit_rate = 3
    tax_year.capgain_rate = 0.15
    tax_year.capgain_ti_rate = 0.05
    tax_year.capgain_ti_limit_s = 31850
    tax_year.capgain_ti_limit_mfs = 31850
    tax_year.capgain_ti_limit_mfj = 63700
    tax_year.capgain_ti_limit_hh = 42650
    tax_year.amt_low_limit_s = 33750
    tax_year.amt_low_limit_mfs = 22500
    tax_year.amt_low_limit_mfj = 45000
    tax_year.amt_low_limit_hh = 33750
    tax_year.tax_income_l1_s = 7825
    tax_year.tax_income_l2_s = 31850
    tax_year.tax_income_l3_s = 77100
    tax_year.tax_income_l4_s = 160850
    tax_year.tax_income_l5_s = 349700
    tax_year.tax_income_l1_mfs = 7825
    tax_year.tax_income_l2_mfs = 31850
    tax_year.tax_income_l3_mfs = 77100
    tax_year.tax_income_l4_mfs = 160850
    tax_year.tax_income_l5_mfs = 349700
    tax_year.tax_income_l1_mfj = 15650
    tax_year.tax_income_l2_mfj = 63700
    tax_year.tax_income_l3_mfj = 128500
    tax_year.tax_income_l4_mfj = 195850
    tax_year.tax_income_l5_mfj = 349700
    tax_year.tax_income_l1_hh = 11200
    tax_year.tax_income_l2_hh = 42650
    tax_year.tax_income_l3_hh = 110100
    tax_year.tax_income_l4_hh = 178350
    tax_year.tax_income_l5_hh = 349700
    tax_year.save

    tax_year = TaxYear.new(:year => 2008)
    tax_year.standard_deduction_s = 5450
    tax_year.standard_deduction_mfs = 5450
    tax_year.standard_deduction_mfj = 10900
    tax_year.standard_deduction_hh = 8000
    tax_year.standard_deduction_extra_s = 1350
    tax_year.standard_deduction_extra_mfs = 1050
    tax_year.standard_deduction_extra_mfj = 1050
    tax_year.standard_deduction_extra_hh = 1350
    tax_year.exemption_amount = 3500
    tax_year.exemption_hi_amount = 2333
    tax_year.exemption_mid_rate = 3
    tax_year.exemption_agi_s = 159950
    tax_year.exemption_agi_mfs = 119975
    tax_year.exemption_agi_mfj = 239950
    tax_year.exemption_agi_hh = 199950
    tax_year.item_limit_s = 159950
    tax_year.item_limit_mfs = 79975
    tax_year.item_limit_mfj = 159950
    tax_year.item_limit_hh = 159950
    tax_year.item_limit_rate = 1.5
    tax_year.capgain_rate = 0.15
    tax_year.capgain_ti_rate = 0
    tax_year.capgain_ti_limit_s = 32350
    tax_year.capgain_ti_limit_mfs = 32350
    tax_year.capgain_ti_limit_mfj = 65100
    tax_year.capgain_ti_limit_hh = 43650
    tax_year.amt_low_limit_s = 46200
    tax_year.amt_low_limit_mfs = 34975
    tax_year.amt_low_limit_mfj = 69950
    tax_year.amt_low_limit_hh = 46200
    tax_year.tax_income_l1_s = 8025
    tax_year.tax_income_l2_s = 32550
    tax_year.tax_income_l3_s = 78850
    tax_year.tax_income_l4_s = 164550
    tax_year.tax_income_l5_s = 357700
    tax_year.tax_income_l1_mfs = 8025
    tax_year.tax_income_l2_mfs = 32550
    tax_year.tax_income_l3_mfs = 78850
    tax_year.tax_income_l4_mfs = 164550
    tax_year.tax_income_l5_mfs = 357700
    tax_year.tax_income_l1_mfj = 16050
    tax_year.tax_income_l2_mfj = 65100
    tax_year.tax_income_l3_mfj = 131450
    tax_year.tax_income_l4_mfj = 200300
    tax_year.tax_income_l5_mfj = 357700
    tax_year.tax_income_l1_hh = 11450
    tax_year.tax_income_l2_hh = 43650
    tax_year.tax_income_l3_hh = 112650
    tax_year.tax_income_l4_hh = 182400
    tax_year.tax_income_l5_hh = 357700
    tax_year.save

    tax_year = TaxYear.new(:year => 2009)
    tax_year.exemption_amount = 3650
    tax_year.standard_deduction_s = 5700
    tax_year.standard_deduction_mfs = 5700
    tax_year.standard_deduction_mfj = 11400
    tax_year.standard_deduction_hh = 8350
    tax_year.tax_income_l1_s = 8350
    tax_year.tax_income_l2_s = 33950
    tax_year.tax_income_l3_s = 82250
    tax_year.tax_income_l4_s = 171550
    tax_year.tax_income_l5_s = 372950
    tax_year.tax_income_l1_mfs = 8350
    tax_year.tax_income_l2_mfs = 33950
    tax_year.tax_income_l3_mfs = 68525
    tax_year.tax_income_l4_mfs = 104425
    tax_year.tax_income_l5_mfs = 186475
    tax_year.tax_income_l1_mfj = 16700
    tax_year.tax_income_l2_mfj = 67900
    tax_year.tax_income_l3_mfj = 137050
    tax_year.tax_income_l4_mfj = 208850
    tax_year.tax_income_l5_mfj = 372950
    tax_year.tax_income_l1_hh = 11950
    tax_year.tax_income_l2_hh = 45500
    tax_year.tax_income_l3_hh = 117450
    tax_year.tax_income_l4_hh = 190200
    tax_year.tax_income_l5_hh = 372950
    tax_year.save

    tax_year = TaxYear.new(:year => 2010)
    tax_year.exemption_amount = 3650
    tax_year.standard_deduction_s = 5700
    tax_year.standard_deduction_mfs = 5700
    tax_year.standard_deduction_mfj = 11400
    tax_year.standard_deduction_hh = 8400
    tax_year.tax_income_l1_s = 8375
    tax_year.tax_income_l2_s = 34000
    tax_year.tax_income_l3_s = 82400
    tax_year.tax_income_l4_s = 171850
    tax_year.tax_income_l5_s = 373650
    tax_year.tax_income_l1_mfs = 8375
    tax_year.tax_income_l2_mfs = 34000
    tax_year.tax_income_l3_mfs = 68650
    tax_year.tax_income_l4_mfs = 104625
    tax_year.tax_income_l5_mfs = 186825
    tax_year.tax_income_l1_mfj = 16750
    tax_year.tax_income_l2_mfj = 68000
    tax_year.tax_income_l3_mfj = 137300
    tax_year.tax_income_l4_mfj = 209250
    tax_year.tax_income_l5_mfj = 373650
    tax_year.tax_income_l1_hh = 11950
    tax_year.tax_income_l2_hh = 45550
    tax_year.tax_income_l3_hh = 117650
    tax_year.tax_income_l4_hh = 190550
    tax_year.tax_income_l5_hh = 373650
    tax_year.save
  end

  def self.down
    tc = TaxConstant.find(1)
    tc.destroy
    ty = TaxYear.find_by_year("2007")
    ty.destroy
    ty = TaxYear.find_by_year("2008")
    ty.destroy
    ty = TaxYear.find_by_year("2009")
    ty.destroy
    ty = TaxYear.find_by_year("2010")
    ty.destroy
  end
end
