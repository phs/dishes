require 'foodcritic'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'kitchen/rake_tasks'

FoodCritic::Rake::LintTask.new
RuboCop::RakeTask.new
RSpec::Core::RakeTask.new
Kitchen::RakeTasks.new

desc 'Run all lint, unit and integration tests'
task default: ['foodcritic', 'rubocop', 'spec', 'kitchen:all']
