require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run all behavior specs for the plugin.'
  task :default => :spec

desc "Run all behavior specs for the plugin"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['./spec/**/*_spec.rb']
  t.spec_opts = ['--options', './spec/spec.opts']
  end

desc "Run only the script named spec/tempspec.rb, if present"
Spec::Rake::SpecTask.new(:tempspec) do |t|
  t.spec_files = FileList['./spec/tempspec.rb']
  t.spec_opts = ['--options', './spec/spec.opts']
  end
