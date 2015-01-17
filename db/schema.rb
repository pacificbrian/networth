# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1024) do

  create_table "account_balances", :force => true do |t|
    t.integer "account_id"
    t.date    "date"
    t.decimal "balance",            :precision => 16, :scale => 4
    t.decimal "cash_balance",       :precision => 16, :scale => 4
    t.decimal "normalized_balance", :precision => 16, :scale => 4
  end

  add_index "account_balances", ["account_id"], :name => "index_account_balances_on_account_id"

  create_table "account_types", :force => true do |t|
    t.string "name"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "account_type_id",                                 :default => 1
    t.string   "name"
    t.integer  "holder"
    t.string   "number"
    t.integer  "routing"
    t.decimal  "cash_balance",     :precision => 16, :scale => 4, :default => 0.0
    t.decimal  "balance",          :precision => 16, :scale => 4, :default => 0.0
    t.integer  "currency_type_id",                                :default => 1
    t.integer  "payee_length"
    t.integer  "transnum_shift",                                  :default => 0
    t.boolean  "taxable"
    t.boolean  "hidden"
    t.boolean  "watchlist"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "user_id"
    t.integer  "institution_id"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "cash_flow_types", :force => true do |t|
    t.string "name"
  end

  create_table "cash_flows", :force => true do |t|
    t.date     "date"
    t.decimal  "amount",             :precision => 16, :scale => 4
    t.decimal  "report_amount",      :precision => 16, :scale => 4
    t.integer  "account_id"
    t.integer  "payee_id"
    t.integer  "category_id"
    t.integer  "split_from",                                        :default => 0
    t.boolean  "split",                                             :default => false
    t.boolean  "transfer",                                          :default => false
    t.string   "transnum"
    t.string   "memo"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.integer  "repeat_interval_id"
    t.string   "type"
    t.integer  "import_id"
    t.boolean  "needs_review"
    t.integer  "tax_year"
  end

  add_index "cash_flows", ["account_id"], :name => "index_cash_flows_on_account_id"
  add_index "cash_flows", ["category_id"], :name => "index_cash_flows_on_category_id"
  add_index "cash_flows", ["import_id"], :name => "index_cash_flows_on_import_id"
  add_index "cash_flows", ["payee_id"], :name => "index_cash_flows_on_payee_id"
  add_index "cash_flows", ["repeat_interval_id"], :name => "index_cash_flows_on_repeat_interval_id"

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "category_type_id"
    t.boolean "omit_from_pie"
    t.integer "user_id"
  end

  add_index "categories", ["user_id"], :name => "index_categories_on_user_id"

  create_table "category_types", :force => true do |t|
    t.string "name"
  end

  create_table "companies", :force => true do |t|
    t.string "symbol"
    t.string "name"
  end

  create_table "currency_types", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "forex", :force => true do |t|
    t.string  "symbol"
    t.date    "date"
    t.decimal "close",  :precision => 10, :scale => 0
  end

  create_table "forex_symbols", :force => true do |t|
    t.string  "currency_to"
    t.string  "currency_from"
    t.date    "last"
    t.date    "begin"
    t.boolean "auto"
  end

  create_table "global_settings", :force => true do |t|
    t.string  "name"
    t.decimal "value", :precision => 12, :scale => 4
  end

  create_table "imports", :force => true do |t|
    t.integer  "account_id"
    t.datetime "created_on"
  end

  add_index "imports", ["account_id"], :name => "index_imports_on_account_id"

  create_table "institutions", :force => true do |t|
    t.string "name"
  end

  create_table "ofx_accounts", :force => true do |t|
    t.integer "account_id"
    t.integer "institution_id"
    t.string  "login"
    t.string  "password"
    t.integer "payee_length"
    t.integer "transnum_shift", :default => 0
  end

  create_table "payees", :force => true do |t|
    t.string  "name"
    t.string  "address"
    t.integer "category_id",     :default => 1
    t.integer "cash_flow_count"
    t.boolean "skip_on_import"
    t.integer "user_id"
  end

  add_index "payees", ["user_id"], :name => "index_payees_on_user_id"

  create_table "qif_accounts", :force => true do |t|
    t.integer "account_id"
    t.integer "payee_length"
    t.boolean "payee_in_memo"
  end

  create_table "quote_symbols", :force => true do |t|
    t.string  "symbol"
    t.date    "last"
    t.date    "begin"
    t.date    "last_split"
    t.boolean "auto"
  end

  create_table "quotes", :force => true do |t|
    t.string  "symbol"
    t.date    "date"
    t.decimal "open",     :precision => 10, :scale => 0
    t.decimal "high",     :precision => 10, :scale => 0
    t.decimal "low",      :precision => 10, :scale => 0
    t.decimal "close",    :precision => 10, :scale => 0
    t.decimal "volume",   :precision => 10, :scale => 0
    t.decimal "adjclose", :precision => 10, :scale => 0
  end

  create_table "repeat_interval_types", :force => true do |t|
    t.string  "name"
    t.integer "days"
  end

  create_table "repeat_intervals", :force => true do |t|
    t.integer "cash_flow_id"
    t.integer "repeat_interval_type_id"
    t.integer "repeats_left"
    t.decimal "rate",                    :precision => 12, :scale => 4
  end

  create_table "risk_types", :force => true do |t|
    t.string "name"
  end

  create_table "securities", :force => true do |t|
    t.integer "account_id"
    t.integer "security_type_id",                                      :default => 1
    t.integer "security_basis_type_id",                                :default => 1
    t.integer "company_id"
    t.integer "risk_type_id",                                          :default => 3
    t.decimal "shares",                 :precision => 14, :scale => 4, :default => 0.0
    t.decimal "basis",                  :precision => 16, :scale => 4, :default => 0.0
    t.decimal "value",                  :precision => 16, :scale => 4, :default => 0.0
    t.date    "last_quote_update"
  end

  add_index "securities", ["account_id"], :name => "index_securities_on_account_id"
  add_index "securities", ["company_id"], :name => "index_securities_on_company_id"

  create_table "security_alerts", :force => true do |t|
    t.date     "date"
    t.integer  "security_id"
    t.decimal  "price",       :precision => 16, :scale => 4
    t.integer  "percent"
    t.boolean  "floating"
    t.boolean  "raised",                                     :default => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

  add_index "security_alerts", ["security_id"], :name => "index_security_alerts_on_security_id"

  create_table "security_basis_types", :force => true do |t|
    t.string "name"
  end

  create_table "security_types", :force => true do |t|
    t.string "name"
  end

  create_table "security_values", :force => true do |t|
    t.integer "security_id"
    t.date    "date"
    t.decimal "value",       :precision => 16, :scale => 4
  end

  create_table "tax_cash_flows", :force => true do |t|
    t.integer "tax_id"
    t.integer "cash_flow_id"
  end

  create_table "tax_categories", :force => true do |t|
    t.integer "tax_item_id"
    t.integer "category_id"
    t.integer "trade_type_id"
  end

  add_index "tax_categories", ["tax_item_id"], :name => "index_tax_categories_on_tax_item_id"

  create_table "tax_constants", :force => true do |t|
    t.integer "tax_form_id"
    t.integer "interest_allowed"
    t.integer "dividend_allowed"
    t.integer "standard_dependent_base"
    t.integer "standard_dependent_extra"
    t.integer "exemption_hi_agi_s"
    t.integer "exemption_hi_agi_mfs"
    t.integer "exemption_hi_agi_mfj"
    t.integer "exemption_hi_agi_hh"
    t.integer "exemption_mid_amount_s"
    t.integer "exemption_mid_amount_mfs"
    t.integer "exemption_mid_amount_mfj"
    t.integer "exemption_mid_amount_hh"
    t.decimal "exemption_mid_rate",        :precision => 12, :scale => 4
    t.decimal "capgain_collectible_rate",  :precision => 12, :scale => 4
    t.decimal "capgain_unrecaptured_rate", :precision => 12, :scale => 4
    t.integer "caploss_limit_s"
    t.integer "caploss_limit_mfs"
    t.integer "caploss_limit_mfj"
    t.integer "caploss_limit_hh"
    t.integer "amt_mid_limit_s"
    t.integer "amt_mid_limit_mfs"
    t.integer "amt_mid_limit_mfj"
    t.integer "amt_mid_limit_hh"
    t.integer "amt_high_limit_s"
    t.integer "amt_high_limit_mfs"
    t.integer "amt_high_limit_mfj"
    t.integer "amt_high_limit_hh"
    t.decimal "item_medical_rate",         :precision => 12, :scale => 4
    t.decimal "item_jobmisc_rate",         :precision => 12, :scale => 4
    t.integer "item_casualty_theft_min"
    t.decimal "item_casualty_theft_rate",  :precision => 12, :scale => 4
    t.decimal "item_limit_rate",           :precision => 12, :scale => 4
    t.decimal "item_limit_upper_rate",     :precision => 12, :scale => 4
    t.decimal "amt_medical_rate",          :precision => 12, :scale => 4
    t.decimal "amt_low_rate",              :precision => 12, :scale => 4
    t.decimal "amt_mid_rate",              :precision => 12, :scale => 4
    t.integer "tax_table_10"
    t.integer "tax_table_25"
    t.integer "tax_table_50"
    t.integer "tax_table_max"
    t.decimal "tax_l1_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l2_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l3_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l4_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l5_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l6_rate",               :precision => 12, :scale => 4
    t.decimal "tax_l7_rate",               :precision => 12, :scale => 4
  end

  create_table "tax_filing_status", :force => true do |t|
    t.string "name"
    t.string "label", :limit => 20
  end

  create_table "tax_items", :force => true do |t|
    t.string  "name"
    t.string  "type"
    t.integer "tax_type_id"
    t.integer "tax_category_id"
  end

  create_table "tax_regions", :force => true do |t|
    t.string "name"
  end

  create_table "tax_types", :force => true do |t|
    t.string "name"
  end

  create_table "tax_users", :force => true do |t|
    t.integer "user_id"
    t.integer "tax_region_id"
    t.integer "year"
    t.integer "filing_status"
    t.integer "exemptions"
    t.decimal "income",             :precision => 16, :scale => 4
    t.decimal "agi_income",         :precision => 16, :scale => 4
    t.decimal "taxable_income",     :precision => 16, :scale => 4
    t.decimal "for_agi",            :precision => 16, :scale => 4
    t.decimal "from_agi",           :precision => 16, :scale => 4
    t.decimal "standard_deduction", :precision => 16, :scale => 4
    t.decimal "itemized_deduction", :precision => 16, :scale => 4
    t.decimal "exemption",          :precision => 16, :scale => 4
    t.decimal "credits",            :precision => 16, :scale => 4
    t.decimal "payments",           :precision => 16, :scale => 4
    t.decimal "base_tax",           :precision => 16, :scale => 4
    t.decimal "other_tax",          :precision => 16, :scale => 4
    t.decimal "owed_tax",           :precision => 16, :scale => 4
    t.decimal "unpaid_tax",         :precision => 16, :scale => 4
  end

  add_index "tax_users", ["user_id"], :name => "index_tax_users_on_user_id"

  create_table "tax_years", :force => true do |t|
    t.integer "year"
    t.integer "tax_form_id"
    t.integer "standard_deduction_s"
    t.integer "standard_deduction_mfs"
    t.integer "standard_deduction_mfj"
    t.integer "standard_deduction_hh"
    t.integer "standard_deduction_extra_s"
    t.integer "standard_deduction_extra_mfs"
    t.integer "standard_deduction_extra_mfj"
    t.integer "standard_deduction_extra_hh"
    t.integer "exemption_amount"
    t.integer "exemption_hi_amount"
    t.decimal "exemption_mid_rate",           :precision => 12, :scale => 4
    t.integer "exemption_agi_s"
    t.integer "exemption_agi_mfs"
    t.integer "exemption_agi_mfj"
    t.integer "exemption_agi_hh"
    t.integer "item_limit_s"
    t.integer "item_limit_mfs"
    t.integer "item_limit_mfj"
    t.integer "item_limit_hh"
    t.decimal "item_limit_rate",              :precision => 12, :scale => 4
    t.decimal "capgain_rate",                 :precision => 12, :scale => 4
    t.decimal "capgain_ti_rate",              :precision => 12, :scale => 4
    t.integer "capgain_ti_limit_s"
    t.integer "capgain_ti_limit_mfs"
    t.integer "capgain_ti_limit_mfj"
    t.integer "capgain_ti_limit_hh"
    t.integer "amt_low_limit_s"
    t.integer "amt_low_limit_mfs"
    t.integer "amt_low_limit_mfj"
    t.integer "amt_low_limit_hh"
    t.integer "tax_income_l1_s"
    t.integer "tax_income_l2_s"
    t.integer "tax_income_l3_s"
    t.integer "tax_income_l4_s"
    t.integer "tax_income_l5_s"
    t.integer "tax_income_l1_mfs"
    t.integer "tax_income_l2_mfs"
    t.integer "tax_income_l3_mfs"
    t.integer "tax_income_l4_mfs"
    t.integer "tax_income_l5_mfs"
    t.integer "tax_income_l1_mfj"
    t.integer "tax_income_l2_mfj"
    t.integer "tax_income_l3_mfj"
    t.integer "tax_income_l4_mfj"
    t.integer "tax_income_l5_mfj"
    t.integer "tax_income_l1_hh"
    t.integer "tax_income_l2_hh"
    t.integer "tax_income_l3_hh"
    t.integer "tax_income_l4_hh"
    t.integer "tax_income_l5_hh"
    t.integer "tax_income_l6_s"
    t.integer "tax_income_l6_mfs"
    t.integer "tax_income_l6_mfj"
    t.integer "tax_income_l6_hh"
  end

  create_table "taxes", :force => true do |t|
    t.date    "year"
    t.decimal "amount",        :precision => 16, :scale => 4
    t.integer "user_id"
    t.integer "tax_region_id"
    t.integer "tax_item_id"
    t.integer "tax_type_id"
    t.string  "memo"
  end

  add_index "taxes", ["user_id"], :name => "index_taxes_on_user_id"

  create_table "trade_gains", :force => true do |t|
    t.integer "sell_id"
    t.integer "buy_id"
    t.integer "days_held"
    t.decimal "shares",          :precision => 14, :scale => 4
    t.decimal "adjusted_shares", :precision => 14, :scale => 4
    t.decimal "basis",           :precision => 16, :scale => 4
  end

  create_table "trade_types", :force => true do |t|
    t.string "name"
  end

  create_table "trades", :force => true do |t|
    t.date     "date"
    t.integer  "account_id"
    t.integer  "security_id"
    t.integer  "trade_type_id"
    t.decimal  "shares",          :precision => 14, :scale => 4
    t.decimal  "adjusted_shares", :precision => 14, :scale => 4
    t.decimal  "amount",          :precision => 16, :scale => 4
    t.decimal  "price",           :precision => 16, :scale => 4
    t.decimal  "basis",           :precision => 16, :scale => 4
    t.boolean  "closed",                                         :default => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "import_id"
    t.boolean  "needs_review"
    t.integer  "tax_year"
  end

  add_index "trades", ["import_id"], :name => "index_trades_on_import_id"
  add_index "trades", ["security_id"], :name => "index_trades_on_security_id"

  create_table "user_settings", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
    t.decimal "value",   :precision => 12, :scale => 4
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "openid"
    t.string   "email"
    t.string   "first_name",                :limit => 80
    t.string   "last_name",                 :limit => 80
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.integer  "cashflow_limit",                          :default => 200
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

end
