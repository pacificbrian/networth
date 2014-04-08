class CreatePayees < ActiveRecord::Migration
  def self.up
    create_table :payees do |t|
      t.string :name
      t.string :address
      t.integer :category_id, :default => 1
      t.decimal :cash_flow_count
      t.boolean :skip_on_import
    end
  end

  def self.down
    drop_table :payees
  end
end
