begin
  require 'rspec/core/rake_task'
rescue LoadError
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ["--order", "rand", "--color"]
end
