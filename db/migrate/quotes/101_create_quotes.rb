class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.string :symbol
      t.date :date
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :volume
      t.decimal :adjclose
    end

    create_table :quote_symbols do |t|
      t.string :symbol
      t.date :last
      t.date :begin
      t.date :last_split
      t.boolean :auto
    end

    create_table :forex do |t|
      t.string :symbol
      t.date :date
      t.decimal :close
    end
	
    create_table :forex_symbols do |t|
      t.string :currency_to
      t.string :currency_from
      t.date :last
      t.date :begin
      t.boolean :auto
    end
  end

  def self.down
    drop_table :quotes
    drop_table :quote_symbols
    drop_table :forex
    drop_table :forex_symbols
  end
end
