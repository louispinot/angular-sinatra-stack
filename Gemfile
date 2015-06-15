source 'https://rubygems.org'

gem 'sinatra'
gem 'unicorn'
gem 'pg'
gem 'sinatra-activerecord'
gem 'le'                    # logentries, sinatra-logentries wasn't working with latest version of Sinatra when we tried it
gem 'bunny'                 , '~> 1.4.0'
gem 'oauth2'

# enforces HTTPS/SSL (TLS) connections by redirecting normal TCP/HTTP connections.
# configure Rack::SslEnforcer in your app.rb (?????????????????) file (see https://github.com/tobmatth/rack-ssl-enforcer)
gem 'rack-ssl-enforcer'

gem 'compassshared', git: 'git@github.com:CompassInc/CompassShared.git', :ref => '445fa38068'
# gem 'compassshared', :path => '../compassshared'

# setup our test group and require rspec

group :development, :local do
  gem 'rspec'
  gem 'rake'
  gem 'rack-test'
  gem 'pry'
  gem 'factory_girl'
end
