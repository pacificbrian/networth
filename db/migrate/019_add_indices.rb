class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :cash_flows, :account_id, :unique => false
    add_index :cash_flows, :payee_id, :unique => false
    add_index :cash_flows, :category_id, :unique => false
    add_index :cash_flows, :repeat_interval_id, :unique => false
    add_index :cash_flows, :import_id, :unique => false
    add_index :trades, :security_id, :unique => false
    add_index :trades, :import_id, :unique => false
    add_index :security_alerts, :security_id, :unique => false
    add_index :securities, :account_id, :unique => false
    add_index :securities, :company_id, :unique => false
    add_index :imports, :account_id, :unique => false
    add_index :account_balances, :account_id, :unique => false
    add_index :tax_categories, :tax_item_id, :unique => false
    add_index :accounts, :user_id, :unique => false
    add_index :payees, :user_id, :unique => false
    add_index :categories, :user_id, :unique => false
    add_index :taxes, :user_id, :unique => false
    add_index :tax_users, :user_id, :unique => false
    #add_index :quotes, :symbol, :unique => false
  end

  def self.down
    remove_index :cash_flows, :account_id
    remove_index :cash_flows, :payee_id
    remove_index :cash_flows, :category_id
    remove_index :cash_flows, :repeat_interval_id
    remove_index :cash_flows, :import_id
    remove_index :trades, :security_id
    remove_index :trades, :import_id
    remove_index :security_alerts, :security_id
    remove_index :securities, :account_id
    remove_index :securities, :company_id
    remove_index :imports, :account_id
    remove_index :account_balances, :account_id
    remove_index :tax_categories, :tax_item_id
    remove_index :accounts, :user_id
    remove_index :payees, :user_id
    remove_index :categories, :user_id
    remove_index :taxes, :user_id
    remove_index :tax_users, :user_id
  end
end
