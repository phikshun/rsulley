require 'rubygems'
require 'rake'
require 'rake/clean'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rsulley"
    gem.summary = %Q{Port and update of the Python Sulley fuzzing library.}
    gem.email = "devinkinch@gmail.com"
    gem.homepage = "http://github.com/phikshun/rsulley"
    gem.authors = ["dkinch"]
    gem.description   = <<-EOD
      This gem is a port of the Python Sulley fuzzing library.  It provides similar
      functionality with a Ruby DSL, and extends some of the features such as socket
      handling code.
    EOD
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rsulley #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rsulley.rb"
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  def egrep(pattern)
    Dir['**/*.rb'].each do |fn|
      count = 0
      open(fn) do |f|
        while line = f.gets
          count += 1
          if line =~ pattern
            puts "#{fn}:#{count}:#{line}"
          end
        end
      end
    end
  end
  egrep /(FIXME|TODO|TBD)/
end