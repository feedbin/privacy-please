require 'etc'

threads_count = ENV.fetch("MAX_THREADS", 64)
threads     threads_count, threads_count
workers     ENV.fetch("WEB_CONCURRENCY", Etc.nprocessors)
port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RACK_ENV", "development")
