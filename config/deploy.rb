set :scm, :git
set :application, "utpjudge"
set :repository,  "https://github.com/in-silico/utpjudge.git"
#set :user, "root"
#set :password, "judge"
set :deploy_to, "/var/www/apps/#{application}"
#set :deploy_via, :remote_cache
set :use_sudo, false
set :rvm_type, :system

require 'rvm/capistrano'

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run

#default_run_options[:shell] = '/bin/bash'

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:

after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:restart"


namespace :deploy do
  task :bundle_gems do
    run "cd #{deploy_to}/current && /usr/local/rvm/gems/ruby-2.0.0-p247@global/bin/bundle install"
  end
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :seed do
    run "cd #{deploy_to}/current && /usr/local/rvm/gems/ruby-2.0.0-p247@global/bin/rake RAILS_ENV=production db:seed"
  end
 
end

