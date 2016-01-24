class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :global_settings do |t|
      t.string :name
      t.decimal "value",   :precision => 12, :scale => 4
    end

    create_table :user_settings do |t|
      t.integer :user_id
      t.string :name
      t.decimal "value",   :precision => 12, :scale => 4
    end

    GlobalSetting.create(:name => 'DefaultUser', :value => 1)
    UserSetting.create(:name => 'CashFlowDisplayLimit', :value => 200)
    UserSetting.create(:name => 'AccountSecuritiesOnLogin', :value => 1)
    UserSetting.create(:name => 'BalancesOnLogin', :value => 0)
    UserSetting.create(:name => 'RefreshOnLogin', :value => 0)
    UserSetting.create(:name => 'AccountSecuritiesOnRefresh', :value => 1)
    UserSetting.create(:name => 'BalancesOnRefresh', :value => 0)
    UserSetting.create(:name => 'ImportOnRefresh', :value => 0)
    UserSetting.create(:name => 'QuotesOnRefresh', :value => 0)
    UserSetting.create(:name => 'BalancesOnAccountShow', :value => 0)
  end

  def self.down
    drop_table :global_settings
    drop_table :user_settings
  end
end
