require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :specs do
  task.pattern = Dir['spec/**/*_spec.rb']
end

namespace :db do
  desc 'generate application test database'
  task :create, [:username] do |_, args|
    user = args[:username] || 'postgres'
    sh "psql -c 'create database automated_survey_sinatra_test;' -U #{user}"
  end
end

task default: :spec
