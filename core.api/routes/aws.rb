# AWS ELB health check
health_check = lambda do
  "(Hard)Core is up at #{Time.now}!"
end

get '/health_check/?', &health_check