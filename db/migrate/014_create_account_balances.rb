class CreateAccountBalances < ActiveRecord::Migration
  def self.up
    create_table :security_values do |t|
      t.integer :security_id
      t.date :date
      t.decimal :value, :precision => 16, :scale => 4
    end

    create_table :account_balances do |t|
      t.integer :account_id
      t.date :date
      t.decimal :balance, :precision => 16, :scale => 4
      t.decimal :cash_balance, :precision => 16, :scale => 4
      t.decimal :normalized_balance, :precision => 16, :scale => 4
    end
  end

  def self.down
    drop_table :security_values
    drop_table :account_balances
  end
end
