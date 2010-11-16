require 'rubygems'
require 'burke'
require 'treetop'
require 'cucumber/rake/task'

Burke.setup do
  name      'coal'
  summary   'Enables low-level code to coexist with Ruby.'
  author    'Aiden Nibali'
  email     'dismal.denizen@gmail.com'
  homepage  'http://github.com/dismaldenizen/coal'
  
  dependencies do |d|
    d['treetop'] = '~> 1.4'
    d['libjit-ffi'] = '0.0.0'
  end
  
  clean     %w[.yardoc]
  clobber   %w[pkg doc html coverage]
end

Cucumber::Rake::Task.new

namespace :compile do
  desc 'Compile Treetop grammar'
  task :grammar do
    grammar_file = File.join(*%w[lib coal parser c.treetop])
    output_file = File.join(*%w[lib coal parser treetop_parser.rb])
    
    rm output_file if File.exists? output_file
    Treetop::Compiler::GrammarCompiler.new.compile(grammar_file, output_file)
  end
end

task :cucumber => ['compile:grammar']
task :spec => ['compile:grammar']

