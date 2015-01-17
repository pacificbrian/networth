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

    GlobalSettings.create(:name => 'DefaultUser', :value => 1)
    UserSettings.create(:name => 'BalancesOnRefresh', :value => 0)
    UserSettings.create(:name => 'ImportOnRefresh', :value => 0)
    UserSettings.create(:name => 'SecuritiesOnRefresh', :value => 1)
    UserSettings.create(:name => 'CashFlowShowLimit', :value => 200)
  end

  def self.down
    drop_table :global_settings
    drop_table :user_settings
  end
end
