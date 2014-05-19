class EnhanceTaxes < ActiveRecord::Migration
  def self.up
    create_table :tax_constants do |t|
      t.integer :tax_form_id

      t.integer :interest_allowed
      t.integer :dividend_allowed
      t.integer :standard_dependent_base
      t.integer :standard_dependent_extra

      t.integer :exemption_hi_agi_s
      t.integer :exemption_hi_agi_mfs
      t.integer :exemption_hi_agi_mfj
      t.integer :exemption_hi_agi_hh
      t.integer :exemption_mid_amount_s
      t.integer :exemption_mid_amount_mfs
      t.integer :exemption_mid_amount_mfj
      t.integer :exemption_mid_amount_hh
      t.decimal :exemption_mid_rate, :precision => 12, :scale => 4

      t.decimal :capgain_collectible_rate, :precision => 12, :scale => 4
      t.decimal :capgain_unrecaptured_rate, :precision => 12, :scale => 4

      t.integer :caploss_limit_s
      t.integer :caploss_limit_mfs
      t.integer :caploss_limit_mfj
      t.integer :caploss_limit_hh

      t.integer :amt_mid_limit_s
      t.integer :amt_mid_limit_mfs
      t.integer :amt_mid_limit_mfj
      t.integer :amt_mid_limit_hh
      t.integer :amt_high_limit_s
      t.integer :amt_high_limit_mfs
      t.integer :amt_high_limit_mfj
      t.integer :amt_high_limit_hh

      t.decimal :item_medical_rate, :precision => 12, :scale => 4
      t.decimal :item_jobmisc_rate, :precision => 12, :scale => 4
      t.integer :item_casualty_theft_min
      t.decimal :item_casualty_theft_rate, :precision => 12, :scale => 4
      t.decimal :item_limit_rate, :precision => 12, :scale => 4
      t.decimal :item_limit_upper_rate, :precision => 12, :scale => 4

      t.decimal :amt_medical_rate, :precision => 12, :scale => 4
      t.decimal :amt_low_rate, :precision => 12, :scale => 4
      t.decimal :amt_mid_rate, :precision => 12, :scale => 4

      t.integer :tax_table_10
      t.integer :tax_table_25
      t.integer :tax_table_50
      t.integer :tax_table_max

      t.decimal :tax_l1_rate, :precision => 12, :scale => 4
      t.decimal :tax_l2_rate, :precision => 12, :scale => 4
      t.decimal :tax_l3_rate, :precision => 12, :scale => 4
      t.decimal :tax_l4_rate, :precision => 12, :scale => 4
      t.decimal :tax_l5_rate, :precision => 12, :scale => 4
      t.decimal :tax_l6_rate, :precision => 12, :scale => 4
    end

    create_table :tax_years do |t|
      t.integer :year
      t.integer :tax_form_id

      t.integer :standard_deduction_s
      t.integer :standard_deduction_mfs
      t.integer :standard_deduction_mfj
      t.integer :standard_deduction_hh
      t.integer :standard_deduction_extra_s
      t.integer :standard_deduction_extra_mfs
      t.integer :standard_deduction_extra_mfj
      t.integer :standard_deduction_extra_hh

      t.integer :exemption_amount
      t.integer :exemption_hi_amount
      t.decimal :exemption_mid_rate, :precision => 12, :scale => 4
      t.integer :exemption_agi_s
      t.integer :exemption_agi_mfs
      t.integer :exemption_agi_mfj
      t.integer :exemption_agi_hh

      t.integer :item_limit_s
      t.integer :item_limit_mfs
      t.integer :item_limit_mfj
      t.integer :item_limit_hh
      t.decimal :item_limit_rate, :precision => 12, :scale => 4

      t.decimal :capgain_rate, :precision => 12, :scale => 4
      t.decimal :capgain_ti_rate, :precision => 12, :scale => 4
      t.integer :capgain_ti_limit_s
      t.integer :capgain_ti_limit_mfs
      t.integer :capgain_ti_limit_mfj
      t.integer :capgain_ti_limit_hh

      t.integer :amt_low_limit_s
      t.integer :amt_low_limit_mfs
      t.integer :amt_low_limit_mfj
      t.integer :amt_low_limit_hh

      t.integer :tax_income_l1_s
      t.integer :tax_income_l2_s
      t.integer :tax_income_l3_s
      t.integer :tax_income_l4_s
      t.integer :tax_income_l5_s
      t.integer :tax_income_l1_mfs
      t.integer :tax_income_l2_mfs
      t.integer :tax_income_l3_mfs
      t.integer :tax_income_l4_mfs
      t.integer :tax_income_l5_mfs
      t.integer :tax_income_l1_mfj
      t.integer :tax_income_l2_mfj
      t.integer :tax_income_l3_mfj
      t.integer :tax_income_l4_mfj
      t.integer :tax_income_l5_mfj
      t.integer :tax_income_l1_hh
      t.integer :tax_income_l2_hh
      t.integer :tax_income_l3_hh
      t.integer :tax_income_l4_hh
      t.integer :tax_income_l5_hh
    end

    create_table :tax_users do |t|
      t.integer :user_id
      t.integer :tax_region_id
      t.integer :year
      t.integer :filing_status
      t.integer :exemptions
      
      t.decimal :income, :precision => 16, :scale => 4
      t.decimal :agi_income, :precision => 16, :scale => 4
      t.decimal :taxable_income, :precision => 16, :scale => 4
      t.decimal :for_agi, :precision => 16, :scale => 4
      t.decimal :from_agi, :precision => 16, :scale => 4
      t.decimal :standard_deduction, :precision => 16, :scale => 4
      t.decimal :itemized_deduction, :precision => 16, :scale => 4
      t.decimal :exemption, :precision => 16, :scale => 4
      t.decimal :credits, :precision => 16, :scale => 4
      t.decimal :payments, :precision => 16, :scale => 4
      t.decimal :base_tax, :precision => 16, :scale => 4
      t.decimal :other_tax, :precision => 16, :scale => 4
      t.decimal :owed_tax, :precision => 16, :scale => 4
      t.decimal :unpaid_tax, :precision => 16, :scale => 4
    end
  end

  def self.down
    drop_table :tax_years
    drop_table :tax_constants
    drop_table :tax_users
  end
end
