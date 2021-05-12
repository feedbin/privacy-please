set :application, "privacy-please"
set :repo_url, "git@github.com:feedbin/#{fetch(:application)}.git"
set :deploy_to, "/srv/apps/#{fetch(:application)}"
set :branch, "main"

set :bundle_jobs, 4
set :log_level, :info

namespace :deploy do
  desc "Restart #{fetch(:application)} processes"
  task :binstubs do
    on roles :all do
      within release_path do
        execute :bundle, :binstubs, :puma, "--path", "./sbin"
      end
    end
  end
  task :restart do
    on roles :all do
      execute :systemctl, "is-active", fetch(:application)
      execute :sudo, :systemctl, :kill, "--signal", "SIGUSR1", fetch(:application)
    rescue SSHKit::Command::Failed
      execute :sudo, :systemctl, :start, fetch(:application)
    end
  end
end

after "deploy:published", "deploy:binstubs"
after "deploy:published", "deploy:restart"
