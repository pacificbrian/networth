class CreateTradeGains < ActiveRecord::Migration
  def self.up
    create_table :trade_gains do |t|
      t.integer :sell_id
      t.integer :buy_id
      t.integer :days_held
      t.decimal :shares
      t.decimal :adjusted_shares
      t.decimal :basis
    end
  end

  def self.down
    drop_table :trade_gains
  end
end
