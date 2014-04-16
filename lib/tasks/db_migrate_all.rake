namespace :db do
  desc "Perform Migrations"
  task :migrate_all do
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:migrate_quotes"].invoke
  end
  task :migrate_quotes do
    ActiveRecord::Base.establish_connection "nw_quotes"
    ActiveRecord::Migrator.migrate("db/migrate/quotes")
  end
end
