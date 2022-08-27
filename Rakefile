require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--pattern "spec/**/*_spec.rb,plugin_spec/**/*_spec.rb" --format documentation'
end

task :default => 'spec'
