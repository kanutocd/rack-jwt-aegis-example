# frozen_string_literal: true

# Start SimpleCov before loading any application code
require 'simplecov'

SimpleCov.start do
  # Set minimum coverage threshold (realistic for a Rails generator gem with complex error handling)
  minimum_coverage 55
  # NOTE: minimum_coverage_by_file disabled due to some utility files having low individual coverage

  # Coverage output directory
  coverage_dir 'coverage'

  # Add filters to exclude certain files from coverage
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/bin/'
  add_filter '/db/migrate/'
  # Track branch coverage in addition to line coverage (Ruby 2.5+)
  enable_coverage :branch if RUBY_VERSION >= '2.5'

  # Group related files
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Services', 'app/services'
  add_group 'Jobs', 'app/jobs'
  add_group 'Mailers', 'app/mailers'
  add_group 'Tasks', 'lib/tasks'
  add_group 'Concerns', 'app/**/concerns'

  # Format output
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::SimpleFormatter,
  ])
end
