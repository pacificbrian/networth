class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :account_type_id, :default => 1
      t.string :name
      t.integer :holder
      t.string :number
      t.integer :routing
      t.decimal :cash_balance, :default => 0
      t.decimal :balance, :default => 0
      t.integer :currency_type_id, :default => 1
      t.integer :payee_length
      t.integer :transnum_shift, :default => 0
      t.boolean :taxable
      t.boolean :hidden
      t.boolean :watchlist
      t.timestamps
    end

    create_table :account_types do |t|
      t.string :name
    end

    AccountType.create(:name => 'Cash')
    AccountType.create(:name => 'Checking/Deposit')
    AccountType.create(:name => 'Credit Card')
    AccountType.create(:name => 'Investment')
    AccountType.create(:name => 'Health Care')
    AccountType.create(:name => 'Loan')
    AccountType.create(:name => 'Asset')
  end

  def self.down
    drop_table :accounts
    drop_table :account_types
  end
end
