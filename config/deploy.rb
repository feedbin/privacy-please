set :application, "privacy-please"
set :repo_url, "git@github.com:feedbin/#{fetch(:application)}.git"
set :deploy_to, "/srv/apps/#{fetch(:application)}"

set :bundle_jobs, 4
set :log_level, :info

namespace :deploy do
  desc "Restart #{fetch(:application)} processes"
  task :restart do
    on roles :all do
      execute :sudo, :systemctl, :restart, fetch(:application)
    rescue SSHKit::Command::Failed
      execute :sudo, :systemctl, :start, fetch(:application)
    end
  end
end

after "deploy:published", "deploy:restart"
