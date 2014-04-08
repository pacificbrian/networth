class CreateSecurities < ActiveRecord::Migration
  def self.up
    create_table :securities do |t|
      t.integer :account_id
      t.integer :security_type_id
      t.integer :risk_type_id
      t.string :symbol
      t.decimal :shares, :default => 0
      t.decimal :basis, :default => 0
      t.decimal :value, :default => 0
    end

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
    end

    create_table :security_types do |t|
      t.string :name
    end

    create_table :risk_types do |t|
      t.string :name
    end

    SecurityType.create(:name => 'Stock')
    SecurityType.create(:name => 'Bond')
    SecurityType.create(:name => 'Money Market')
    SecurityType.create(:name => 'Mutual Fund')
    SecurityType.create(:name => 'Foreign Currency')
    SecurityType.create(:name => 'Foreign Fund')
    SecurityType.create(:name => 'Foreign Stock')
    SecurityType.create(:name => 'Short Fund')
    SecurityType.create(:name => 'Short Stock')
    SecurityType.create(:name => 'Commodity Fund')
    SecurityType.create(:name => 'Commodity Stock')
    SecurityType.create(:name => 'Precious Metal')
    SecurityType.create(:name => 'Real Estate')
    SecurityType.create(:name => 'Trusts')
    SecurityType.create(:name => 'Options')

    RiskType.create(:name => 'Growth')
    RiskType.create(:name => 'Income')
    RiskType.create(:name => 'Investment')
    RiskType.create(:name => 'Preservation')
    RiskType.create(:name => 'Speculation')
  end

  def self.down
    drop_table :securities
    drop_table :security_types
    drop_table :risk_types
    drop_table :quotes
    drop_table :quote_symbols
  end
end
