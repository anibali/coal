require 'rubygems'
require 'burke'
require 'treetop'
require 'fileutils'

Burke.enable_all

Burke.setup do
  name      'coal'
  summary   "A low-level language which may be embedded in Ruby code"
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

namespace :compile do
  desc 'Compile Treetop grammar'
  task :grammar do
    grammar_file = File.join(*%w[lib coal parser coal.treetop])
    output_file = File.join(*%w[lib coal parser coal_treetop.rb])
    
    FileUtils.remove(output_file) if File.exists? output_file
    Treetop::Compiler::GrammarCompiler.new.compile(grammar_file, output_file)
  end
end

task :spec => ['compile:grammar']
task :gem => ['compile:grammar']
task :gems => ['compile:grammar']

