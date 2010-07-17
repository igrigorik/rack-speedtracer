require 'rake'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'rack-speedtracer'
    gemspec.summary = 'SpeedTracer middleware for server side debugging'
    gemspec.description = gemspec.summary
    gemspec.email = 'ilya@igvita.com'
    gemspec.homepage = 'http://github.com/igrigorik/rack-speedtracer'
    gemspec.authors = ['Ilya Grigorik']
    gemspec.add_dependency('rack')
    gemspec.add_dependency('uuid')
    gemspec.add_dependency('yajl-ruby')
    gemspec.rubyforge_project = 'rack-speedtracer'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org'
end

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.ruby_opts = ['-rtest/unit']
  t.spec_files = FileList['spec/**/*_spec.rb']
end


