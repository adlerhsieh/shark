require 'yaml'

YAML.load_file(File.expand_path("../../.env", __FILE__)).each do |key, value|
  ENV[key] = value.to_s
end

# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "shark"
set :repo_url, ENV["DEPLOY_REPO_URL"]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "~/rails/shark"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  namespace :db do
    task :migrate do
      on roles(:web) do
        execute "cd #{fetch(:deploy_to)}/current && RAILS_ENV=bundle exec rake db:migrate"
      end
    end
  end

  task :config do
    on roles(:web) do
      execute "cp #{fetch(:deploy_to)}/shared/.env #{fetch(:deploy_to)}/current"
    end
  end
end

after :deploy, "deploy:config"
after :deploy, "deploy:db:migrate"
