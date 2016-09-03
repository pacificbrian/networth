class AddClientUid < ActiveRecord::Migration
  def self.up
    add_column :institutions, :client_uid, :string, :limit => 32
    add_column :ofx_accounts, :client_uid, :string, :limit => 32
    add_column :accounts, :ofx_index, :integer
  end

  def self.down
    remove_column :institutions, :client_uid
    remove_column :ofx_accounts, :client_uid
    remove_column :accounts, :ofx_index
  end
end
