class CreateSecurityAlerts < ActiveRecord::Migration
  def self.up
    create_table :security_alerts do |t|
      t.date :date
      t.integer :security_id
      t.decimal :price
      t.integer :percent
      t.boolean :floating
      t.boolean :raised, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :security_alerts
  end
end
