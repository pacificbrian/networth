class CreateGtd < ActiveRecord::Migration
  def self.up
    create_table :gtd_tasks do |t|
      t.string :name
      t.string :description
      t.decimal :user_id
      t.decimal :task_type_id
    end
  end

  def self.down
    drop_table :gtd_tasks
  end
end
