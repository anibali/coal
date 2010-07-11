require 'rubygems'
require 'jeweler'
require 'treetop'
require 'fileutils'

Jeweler::Tasks.new do |s|
  s.name = 'coal'
  s.summary = "Low-level language which may be embedded in Ruby code"
  s.description = s.summary
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  
  s.add_dependency 'treetop', '>= 1.4.0'
  
  s.files = %w(LICENSE README Rakefile VERSION) + Dir.glob("{lib,spec}/**/*")
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.rdoc_options << '--title' << "#{s.name} #{File.read 'VERSION'}" <<
                    '--main' << 'README' << '--line-numbers'
end

Jeweler::GemcutterTasks.new

begin
  require 'spec/rake/spectask'

  desc "Run all RSpec examples."
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts << '--colour --format progress'
    t.ruby_opts << '-rrubygems'
  end
rescue LoadError
end

namespace :compile do
  desc 'Compile Treetop grammar into a parser.'
  task :grammar do
    grammar_file = File.join(*%w[lib coal coal.treetop])
    output_file = File.join(*%w[lib coal coal_treetop.rb])
    
    FileUtils.remove(output_file) if File.exists? output_file
    Treetop::Compiler::GrammarCompiler.new.compile(grammar_file, output_file)
  end
end

task :spec => ['compile:grammar']
task :build => ['compile:grammar']

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.options = [
      '--title', "Coal #{File.read 'VERSION'}",
      '--readme', 'README',
      '-m', 'markdown',
      '--files', 'LICENSE'
    ]
  end
rescue LoadError
end

