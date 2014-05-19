class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      t.date :date
      t.integer :account_id
      t.integer :security_id
      t.integer :trade_type_id
      t.decimal :shares, :precision => 14, :scale => 4
      t.decimal :adjusted_shares, :precision => 14, :scale => 4
      t.decimal :amount, :precision => 16, :scale => 4
      t.decimal :price, :precision => 16, :scale => 4
      t.decimal :basis, :precision => 16, :scale => 4
      t.boolean :closed, :default => false

      t.timestamps
    end

    create_table :trade_types do |t|
      t.string :name
    end

    TradeType.create(:name => 'Buy')
    TradeType.create(:name => 'Sell')
    TradeType.create(:name => 'Dividend')
    TradeType.create(:name => 'Distribution')
    TradeType.create(:name => 'Dividend (Reinvest)')
    TradeType.create(:name => 'Distribution (Reinvest)')
    TradeType.create(:name => 'Shares In')
    TradeType.create(:name => 'Shares Out')
    TradeType.create(:name => 'Spilt Shares')
  end

  def self.down
    drop_table :trades
    drop_table :trade_types
  end
end
