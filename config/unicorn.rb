require "etc"

worker_processes Etc.nprocessors
timeout 30
preload_app true
user "app", "app"

working_directory "/srv/apps/privacy-please/current"

listen "/run/privacy-please.sock"
pid "/run/privacy-please.pid"

before_fork do |server, worker|
  old_pid = "/run/unicorn.pid.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
