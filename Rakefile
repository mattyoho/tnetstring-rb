require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format=progress --color)
end

task :default => :spec


namespace :gem do
  desc 'Builds the gem from the current gemspec'
  task :build do
    system 'mkdir -p ./pkg'
    system 'gem build ./tnetstring.gemspec'
    system 'mv ./tnetstring-*.gem ./pkg/'
  end
end

desc 'Remove generated code'
task :clobber do
  rm_rf './pkg'
end
