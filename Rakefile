# Prevent "rake release" from pushing the gem
ENV['gem_push'] = 'off'

require 'bundler'
require 'rspec/core/rake_task'
require 'rake/clean'
require 'yard'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |c|
  options = ['--color']
  options += ['--format', 'documentation']
  c.rspec_opts = options
end

task default: :build

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

CLEAN.include 'pkg'
CLOBBER.include 'doc'
