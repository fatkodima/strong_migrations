namespace :strong_migrations do
  # https://www.pgrs.net/2008/03/13/alphabetize-schema-rb-columns/
  task :alphabetize_columns do
    $stderr.puts "Dumping schema"
    ActiveRecord::Base.logger.level = Logger::INFO

    require "strong_migrations/alphabetize_columns"
    ActiveRecord::Base.connection.class.prepend StrongMigrations::AlphabetizeColumns
    if ActiveRecord::ConnectionAdapters.const_defined?('PostGISAdapter')
      ActiveRecord::ConnectionAdapters::PostGISAdapter.prepend StrongMigrations::AlphabetizeColumns
    end
    ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend StrongMigrations::AlphabetizeColumns
  end
end

if StrongMigrations::Helpers.supports_multiple_dbs?
  names = []
  databases = ActiveRecord::Tasks::DatabaseTasks.setup_initial_database_yaml
  ActiveRecord::Tasks::DatabaseTasks.for_each(databases) { |name| names << name }

  if names.size > 1
    names.each do |name|
      task "strong_migrations:set_#{name}_database_name" do
        ENV["STRONG_MIGRATIONS_DATABASE_NAME"] = name
      end

      ["migrate", "rollback", "migrate:up", "migrate:down"].each do |task|
        Rake::Task["db:#{task}:#{name}"].enhance(["strong_migrations:set_#{name}_database_name"])
      end
    end

    Rake::Task["db:migrate"].clear

    namespace :db do
      desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
      task :migrate do
        names.each do |name|
          Rake::Task["db:migrate:#{name}"].invoke
        end
      end
    end
  end
end
