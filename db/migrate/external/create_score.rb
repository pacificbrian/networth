class CreateScore < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.real :score
      t.string :symbol
      t.decimal :screener_id
    end
  end

  def self.down
    drop_table :scores
  end
end
