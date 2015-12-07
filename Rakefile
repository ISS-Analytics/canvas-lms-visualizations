Dir.glob('./{models,helpers,controllers,services,values,forms}/*.rb')
  .each do |file|
  require file
end

require 'sinatra/activerecord/rake'
require 'config_env/rake_tasks'
require 'rake/testtask'

task default: [:local_and_running]

desc 'Run specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end

desc 'Local and running'
task :local_and_running do
  Rake::Task['local:local_and_running'].invoke
end

desc 'Heroku and running'
task :heroku_and_running do
  Rake::Task['heroku:up_and_running'].invoke
end

namespace :local do
  desc 'Bundle Install'
  task :bundle_install do
    system 'bundle install --without production'
  end

  desc 'Set up local database'
  task :local_db do
    system 'rake db:migrate'
  end

  desc 'Set up local'
  task local_and_running: [:bundle_install, :local_db] do
  end
end

namespace :heroku do
  desc 'Start a heroku'
  task :create_heroku do
    system "heroku create #{ENV['APP_NAME']}"
  end

  desc 'Push master to heroku'
  task :push_to_heroku do
    system 'git push -f heroku master'
  end

  desc 'Create heroku database'
  task :make_heroku_db do
    system 'heroku addons:create heroku-postgresql:hobby-dev'
  end

  desc 'Set up heroku database'
  task migrate_heroku_db: [:make_heroku_db] do
    system 'heroku run rake db:migrate'
  end

  desc 'Transfer heroku environment variables'
  task :transfer_config_env do
    system 'rake config_env:heroku'
  end

  desc 'And it\'s a wrap'
  task up_and_running: [:create_heroku, :push_to_heroku, :migrate_heroku_db,
                        :transfer_config_env] do
  end
end

desc 'Generate DB & MSG keys'
task :keys_for_config do
  2.times do
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    print 'either key: '
    puts Base64.urlsafe_encode64(key)
  end
end
