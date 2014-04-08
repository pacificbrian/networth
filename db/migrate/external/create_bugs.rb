class CreateBugs < ActiveRecord::Migration
#  establish_connection "nw_bugs"
  def self.up
    create_table :bugs do |t|
      t.string :title
      t.string :description
      t.integer :user_id
      t.integer :reporter_id
      t.integer :bug_status_id
      t.integer :bug_resolution_id
      t.integer :bug_severity_id
      t.integer :bug_target_id
      t.integer :bug_release_id
      t.integer :bug_project_id
      t.integer :bug_component_id
      t.integer :bug_revision_id
      t.timestamps
    end

    create_table :bug_severities do |t|
      t.string :name
    end
    create_table :bug_releases do |t|
      t.string :name
    end

    create_table :bug_expectations do |t|
      t.string :name
    end

    BugSeverity.create(:name => 'Minor')
    BugSeverity.create(:name => 'Normal')
    BugSeverity.create(:name => 'Urgent')
    BugSeverity.create(:name => 'Feature Request')
    BugSeverity.create(:name => 'Enhancement')
    BugSeverity.create(:name => 'Degraded Performance')
    BugSeverity.create(:name => 'Informational')

    BugRelease.create(:name => 'Internal')
    BugRelease.create(:name => '1.0')
    BugRelease.create(:name => '1.2')
    BugRelease.create(:name => '1.4')

    BugExpectation.create(:name => 'Short Term')
    BugExpectation.create(:name => 'Medium Term')
    BugExpectation.create(:name => 'Long Term')
    BugExpectation.create(:name => 'No Plan')
  end

  def self.down
    drop_table :bugs
    drop_table :bug_severities
    drop_table :bug_releases
    drop_table :bug_expectations
  end
end
