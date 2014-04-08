class CreateAccountBalances < ActiveRecord::Migration
  def self.up
    create_table :security_values do |t|
      t.integer :security_id
      t.date :date
      t.decimal :value
    end

    create_table :account_balances do |t|
      t.integer :account_id
      t.date :date
      t.decimal :balance
      t.decimal :cash_balance
      t.decimal :normalized_balance
    end
  end

  def self.down
    drop_table :security_values
    drop_table :account_balances
  end
end
