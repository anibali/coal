require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'coal'
  s.version = '0.0.1'
  s.summary = "Low-level language which may be embedded in Ruby code."
  s.platform = Gem::Platform::RUBY
  s.add_dependency 'mixin', '>= 0.7.0'
  s.add_dependency 'treetop', '>= 1.4.0'
  s.requirements << 'libjit'
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib}/**/*")
end

task :default => ["coal"]

Rake::TestTask.new(spec.name) do |t|
  t.pattern = 'test/**/test_*.rb'
  t.ruby_opts = ['-rrubygems']
  t.warning = false
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

