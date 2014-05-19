class CreateTradeGains < ActiveRecord::Migration
  def self.up
    create_table :trade_gains do |t|
      t.integer :sell_id
      t.integer :buy_id
      t.integer :days_held
      t.decimal :shares, :precision => 14, :scale => 4
      t.decimal :adjusted_shares, :precision => 14, :scale => 4
      t.decimal :basis, :precision => 16, :scale => 4
    end
  end

  def self.down
    drop_table :trade_gains
  end
end
