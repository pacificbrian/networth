class CreateRepeatIntervalTypes < ActiveRecord::Migration
  def self.up
    create_table :repeat_interval_types do |t|
      t.string :name
      t.integer :days
    end

    create_table :repeat_intervals do |t|
      t.integer :cash_flow_id
      t.integer :repeat_interval_type_id
      t.integer :repeats_left
    end

    add_column :cash_flows, :repeat_interval_id, :integer
    add_column :cash_flows, :type, :string	# used for class inheritance

    RepeatIntervalType.create(:name => 'Once', :days => 0)
    RepeatIntervalType.create(:name => 'Weekly', :days => 7)
    RepeatIntervalType.create(:name => 'Bi-Weekly', :days => 14)
    RepeatIntervalType.create(:name => 'Semi-Monthly', :days => 15)
    RepeatIntervalType.create(:name => 'Monthly', :days => 30)
    RepeatIntervalType.create(:name => 'Bi-Monthly', :days => 60)
    RepeatIntervalType.create(:name => 'Quarterly', :days => 90)
    RepeatIntervalType.create(:name => 'Thirds', :days => 120)
    RepeatIntervalType.create(:name => 'Bi-Annually', :days => 180)
    RepeatIntervalType.create(:name => 'Annually', :days => 360)
  end

  def self.down
    drop_table :repeat_interval_types
    drop_table :repeat_intervals
#    remove_column :cash_flows, :repeat_interval
#    remove_column :cash_flows, :type
  end
end
