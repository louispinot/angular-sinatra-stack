require 'rack/test'
require 'pry'

ENV['RACK_ENV'] = 'development'

require File.expand_path( '../../app.rb', __FILE__ )

Dir['../core.api/config/*.rb'].each do |file|
  require File.expand_path( '../../' + file, __FILE__ )
end

Dir['../core.api/models/*.rb'].each do |file|
  require File.expand_path( '../../' + file, __FILE__ )
end

Dir['../core.api/routes/*.rb'].each do |file|
  require File.expand_path( '../../' + file, __FILE__ )
end
Dir['../core.api/services/*.rb'].each do |file|
  require File.expand_path( '../../' + file, __FILE__ )
end

require 'factory_girl'
Dir['./core.api/spec/factories/*.rb'].each {|file| require file}

RSpec.configure do |config|
  config.include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end