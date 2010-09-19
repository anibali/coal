require 'rubygems'
require 'burke'
require 'treetop'
require 'fileutils'

Burke.enable_all

Burke.setup do |s|
  s.name = 'coal'
  s.summary = "A low-level language which may be embedded in Ruby code"
  s.author = 'Aiden Nibali'
  s.email = 'dismal.denizen@gmail.com'
  s.homepage = 'http://github.com/dismaldenizen/coal'
  
  s.dependencies do |d|
    d['treetop'] = '~> 1.4'
    d['libjit-ffi'] = '0.0.0'
  end
  
  s.clean = %w[.yardoc]
  s.clobber = %w[pkg doc html coverage]
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
task :gem => ['compile:grammar']
task :gems => ['compile:grammar']

