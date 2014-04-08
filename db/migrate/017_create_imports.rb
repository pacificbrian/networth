class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports, :force => true do |t|
      t.integer :account_id
      t.timestamp :created_on
    end

    create_table :institutions, :force => true do |t|
      t.string :name
    end
 
    add_column :cash_flows, :import_id, :integer
    add_column :cash_flows, :needs_review, :boolean
    add_column :trades, :import_id, :integer
    add_column :trades, :needs_review, :boolean
    add_column :accounts, :institution_id, :integer
  end

  def self.down
    drop_table :imports
    drop_table :institutions
    remove_column :cash_flows, :import_id
    remove_column :cash_flows, :needs_review
    remove_column :trades, :import_id
    remove_column :trades, :needs_review
    remove_column :accounts, :institution_id
  end
end
