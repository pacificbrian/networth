class CreateCashFlows < ActiveRecord::Migration
  def self.up
    create_table :cash_flows do |t|
      t.date :date
      t.decimal :amount
      t.decimal :report_amount
      t.integer :account_id
      t.integer :payee_id
      t.integer :category_id
      t.integer :split_from, :default => 0
      t.boolean :split, :default => 0
      t.boolean :transfer, :default => 0
      t.string :transnum
      t.string :memo

      t.timestamps
    end

    create_table :cash_flow_types do |t|
      t.string :name
    end

    CashFlowType.create(:name => 'Debit')
    CashFlowType.create(:name => 'Credit')
    CashFlowType.create(:name => 'Debit (Transfer)')
    CashFlowType.create(:name => 'Credit (Transfer)')
  end

  def self.down
    drop_table :cash_flows
    drop_table :cash_flow_types
  end
end
