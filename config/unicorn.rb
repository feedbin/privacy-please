require "etc"

working_directory  File.expand_path("..", __dir__)
shared_directory = File.join(File.expand_path("..", ENV["PWD"]), "shared")
shared_directory = File.directory?(shared_directory) ? shared_directory : ENV["PWD"]

pid    File.join(shared_directory, "tmp", "unicorn.pid")
listen File.join(shared_directory, "tmp", "unicorn.sock")

logger Logger.new($stdout)

worker_processes ENV.fetch("WEB_CONCURRENCY", Etc.nprocessors)
listen           ENV.fetch("PORT", 3000)
