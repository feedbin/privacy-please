require "rake/testtask"

Rake::TestTask.new(:test) do |test|
  test.libs = []
  test.ruby_opts = ["-W0"]
  test.pattern = "test.rb"
end

task default: :test
