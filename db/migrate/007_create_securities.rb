class CreateSecurities < ActiveRecord::Migration
  def self.up
    create_table :securities do |t|
      t.integer :account_id
      t.integer :security_type_id, :default => 1
      t.integer :security_basis_type_id, :default => 1
      t.integer :company_id
      t.integer :risk_type_id, :default => 3
      t.decimal :shares, :default => 0
      t.decimal :basis, :default => 0
      t.decimal :value, :default => 0
      t.date    :last_quote_update
    end

    create_table :companies do |t|
      t.string :symbol
      t.string :name
    end

    create_table :security_alerts do |t|
      t.date :date
      t.integer :security_id
      t.decimal :price
      t.integer :percent
      t.boolean :floating
      t.boolean :raised, :default => false

      t.timestamps
    end

    create_table :security_types do |t|
      t.string :name
    end

    create_table :security_basis_types do |t|
      t.string :name
    end

    create_table :risk_types do |t|
      t.string :name
    end

    SecurityType.create(:name => 'Stock')
    SecurityType.create(:name => 'Mutual Fund')
    SecurityType.create(:name => 'Bond')
    SecurityType.create(:name => 'Bond Fund')
    SecurityType.create(:name => 'Money Market')
    SecurityType.create(:name => 'Foreign Currency')
    SecurityType.create(:name => 'Foreign Stock')
    SecurityType.create(:name => 'Foreign Stock Fund')
    SecurityType.create(:name => 'Foreign Bond')
    SecurityType.create(:name => 'Foreign Bond Fund')
    SecurityType.create(:name => 'Short Stock')
    SecurityType.create(:name => 'Short Fund')
    SecurityType.create(:name => 'Commodity Stock')
    SecurityType.create(:name => 'Commodity Fund')
    SecurityType.create(:name => 'Commodities')
    SecurityType.create(:name => 'Precious Metal')
    SecurityType.create(:name => 'Real Estate')
    SecurityType.create(:name => 'Trusts')
    SecurityType.create(:name => 'Options')

    SecurityBasisType.create(:name => 'FIFO')
    SecurityBasisType.create(:name => 'Average')

    RiskType.create(:name => 'Growth')
    RiskType.create(:name => 'Income')
    RiskType.create(:name => 'Investment')
    RiskType.create(:name => 'Preservation')
    RiskType.create(:name => 'Speculation')
  end

  def self.down
    drop_table :securities
    drop_table :security_alerts
    drop_table :security_types
    drop_table :security_basis_types
    drop_table :companies
    drop_table :risk_types
  end
end
