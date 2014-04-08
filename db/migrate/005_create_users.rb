class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :login,                     :string
      t.column :openid,                    :string
      t.column :email,                     :string
      t.column :first_name,                :string, :limit => 80
      t.column :last_name,                 :string, :limit => 80
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.integer :cashflow_limit, :default => 200
      t.timestamps
    end
#   add_index :users, :login, :unique => true

    add_column :accounts, :user_id, :integer
    add_column :categories, :user_id, :integer
    add_column :payees, :user_id, :integer

    User.create(:login => 'primary')
  end

  def self.down
    drop_table :users

    remove_column :accounts, :user_id
    remove_column :categories, :user_id
    remove_column :payees, :user_id
  end
end
