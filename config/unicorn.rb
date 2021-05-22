require "etc"

worker_processes Etc.nprocessors
timeout 30
preload_app true
user "app", "app"

base_directory = File.expand_path("..", __dir__)
shared_directory = File.join(File.expand_path("..", base_directory), "shared")
shared_directory = File.directory?(shared_directory) ? shared_directory : base_directory

puts '-----------------------------'
puts base_directory
puts shared_directory
puts '-----------------------------'

working_directory base_directory

listen "#{shared_directory}/tmp/unicorn.sock"
pid "#{shared_directory}/tmp/unicorn.pid"

stderr_path "#{shared_directory}/log/unicorn.stderr.log"
stdout_path "#{shared_directory}/log/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = "#{shared_directory}/tmp/unicorn.pid.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
