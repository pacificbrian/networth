class CreateSecurityBasis < ActiveRecord::Migration
  def self.up
    create_table :security_basis_types do |t|
      t.string :name
    end
    SecurityBasisType.create(:name => 'FIFO')
    SecurityBasisType.create(:name => 'Average')
    add_column :securities, :security_basis_type_id, :integer, :default => 1
    add_column :trades, :basis, :decimal
    add_column :trades, :adjusted_shares, :decimal
    add_column :trade_gains, :basis, :decimal
    add_column :trade_gains, :adjusted_shares, :decimal
  end

  def self.down
    drop_table :security_basis_types
  end
end
