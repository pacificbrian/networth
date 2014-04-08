class CreateSessions < ActiveRecord::Migration
  def self.up
      add_column :users, :login,                     :string
      add_column :users, :openid,                    :string
      add_column :users, :email,                     :string
      add_column :users, :first_name,                :string, :limit => 80
      add_column :users, :last_name,                 :string, :limit => 80
      add_column :users, :crypted_password,          :string, :limit => 40
      add_column :users, :salt,                      :string, :limit => 40
      add_column :users, :remember_token,            :string, :limit => 40
      add_column :users, :remember_token_expires_at, :datetime
      add_column :users, :activation_code,           :string, :limit => 40
      add_column :users, :activated_at,              :datetime
  end
end
