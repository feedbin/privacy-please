require 'etc'

workers ENV.fetch("WEB_CONCURRENCY", Etc.nprocessors)
threads_count = ENV.fetch("MAX_THREADS", 24)
threads threads_count, threads_count

environment ENV.fetch("RACK_ENV", "development")

puts ENV.inspect

shared_directory = File.join(File.expand_path("..", ENV["PWD"]), "shared")
shared_directory = File.directory?(shared_directory) ? shared_directory : ENV["PWD"]

pidfile File.join(shared_directory, "tmp", "puma.pid")
bind    File.join("unix://", shared_directory, "tmp", "puma.sock")
