require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/clean'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
    rdoc.rdoc_dir = 'rdoc/'
    rdoc.title    = "OSM Library Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('lib/OSM/objects.rb')
    rdoc.rdoc_files.include('lib/OSM/Database.rb')
    rdoc.rdoc_files.include('lib/OSM/StreamParser.rb')
end

