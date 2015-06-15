
# Redirections to Content Delivery (currently hosted in our AWS S3 bucket)

get '/reports/startup-ecosystem-report-part1' do
  redirect to 'https://s3-us-west-2.amazonaws.com/compasscore/reports/Startup+Ecosystem+Report+Part+1+vers+1.21+%2B+Spain.pdf'
end #get do

get '/reports/startup-genome-report-extra-premature-scaling' do
  redirect to 'https://s3-us-west-2.amazonaws.com/compasscore/reports/Startup+Genome+Report+Extra+-+Premature+Scaling+version+2.pdf'
end #get do

get '/reports/startup-genome-report-v2' do
  redirect to 'https://s3-us-west-2.amazonaws.com/compasscore/reports/Startup+Genome+Report+version+2.pdf'
end #get do

