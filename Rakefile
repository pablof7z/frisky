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

task gem: :build
task :build do
  system "gem build frisky.gemspec"
end

task release: :build do
  version = Frisky::VERSION
  system "git tag -a v#{version} -m 'Tagging #{version}'"
  system "git push --tags"
  system "gem push frisky-#{version}.gem"
  system "rm frisky-#{version}.gem"
end

task default: :spec