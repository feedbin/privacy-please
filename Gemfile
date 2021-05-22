source "https://rubygems.org"
git_source(:github) { |name| "https://github.com/#{name}.git" }

gem "puma"
gem "unicorn"
gem "sinatra"
gem "http"
gem "sd_notify"

group :development do
  gem "capistrano"
  gem "capistrano-bundler"
  gem "foreman"
  gem "standard"
end

group :test do
  gem "minitest"
  gem "rack-test"
  gem "webmock"
end
