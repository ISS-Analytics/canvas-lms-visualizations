Dir.glob('./{models,helpers,controllers,services,values}/*.rb')
  .each do |file|
  puts file
  require file
end

require 'sinatra/activerecord/rake'
require 'config_env/rake_tasks'
require 'rake/testtask'

task default: [:spec]

desc 'Run specs'
Rake::TestTask.new(name = :spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
