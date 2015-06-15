source 'https://rubygems.org'

gem 'sinatra'
# gem 'unicorn'
gem 'pg'
gem 'sinatra-activerecord'

# enforces HTTPS/SSL (TLS) connections by redirecting normal TCP/HTTP connections.
# configure Rack::SslEnforcer in your app.rb (?????????????????) file (see https://github.com/tobmatth/rack-ssl-enforcer)
gem 'rack-ssl-enforcer'

# setup our test group and require rspec

group :development, :local do
  gem 'rspec'
  gem 'rake'
  gem 'pry'
end
