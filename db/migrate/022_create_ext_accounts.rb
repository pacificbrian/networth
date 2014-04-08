class CreateExtAccounts < ActiveRecord::Migration
  def self.up
    create_table :ofx_accounts do |t|
      t.integer :account_id
      t.integer :institution_id
      t.string :login
      t.string :password
      t.integer :payee_length
      t.integer :transnum_shift, :default => 0
    end

    create_table :qif_accounts do |t|
      t.integer :account_id
      t.integer :payee_length
      t.boolean :payee_in_memo
    end
  end
 
  def self.down
    drop_table :ofx_accounts
    drop_table :qif_accounts
  end
end
