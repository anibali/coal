require 'rubygems'
require 'jeweler'
require 'spec/rake/spectask'
require 'rake/testtask'

Jeweler::Tasks.new do |s|
  s.name = 'coal'
  s.summary = "Low-level language which may be embedded in Ruby code"
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  
  s.add_dependency 'mixin', '>= 0.7.0'
  s.add_dependency 'treetop', '>= 1.4.0'
  s.requirements << 'libjit'
  
  s.files = %w(LICENSE README Rakefile VERSION) + Dir.glob("{lib,spec}/**/*")
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.rdoc_options << '--title' << "#{s.name} #{File.read 'VERSION'}" <<
                    '--main' << 'README' << '--line-numbers'
end

Jeweler::GemcutterTasks.new

task :default => ["coal"]

Rake::TestTask.new('coal') do |t|
  t.pattern = 'test/**/test_*.rb'
  t.ruby_opts = ['-rrubygems']
  t.warning = false
end

desc "Run all RSpec examples."
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << '--colour --format nested'
  t.ruby_opts << '-rrubygems'
end

