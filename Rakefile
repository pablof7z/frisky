require "bundler"

Bundler.setup
Bundler.require(:default)

require 'rake'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'frisky'

RSpec::Core::RakeTask.new("spec") do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

desc "Run watchr"
task :watchr do
  sh %{bundle exec watchr .watchr}
end

desc "Run console"
task :console do
  sh %{bundle exec pry -I . -I lib -r ./bin/console.rb}
end