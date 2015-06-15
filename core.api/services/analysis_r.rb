
# local R testing:
# R CMD BATCH "--args db_hostname='localhost' db_username='' db_password='' db_database='compass' db_port='5432'" "Incremental_MLSM_via_PostgreSQL.R" "R_last_execution_output.txt";  cat R_last_execution_output.txt
class AnalysisR



def self.segment_cluster(company_id = nil)
  # We're passing in an optional company id for the situation where a company takes the survey for the second time and already has a segment type
  return self.execute_local_r_code( 'segment', company_id )
end #segment_cluster()

def self.lifestage_cluster()
  return self.execute_local_r_code( 'lifestage' )
end #lifestage_cluster()



#############################################################
private

def self.execute_local_r_code( r_code_type = nil, company_id = nil )
  return false  if ! r_code_type

  # execute R-code in a subshell, R-code will access our (Postgres) database
  # The following files will be creates:  .RData,  R_last_execution_output.txt
  db_config   = Sinatra::Application.settings.database.configurations[ENV['RACK_ENV']]
  db_hostname = db_config["host"]
  db_username = db_config["username"]
  db_password = db_config["password"]
  db_database = db_config["database"]
  db_port     = db_config["port"]

  case r_code_type
    when 'segment'
      r_directory = CORE_API_DIRECTORY + 'analysis-r/cluster-segment'
      r_mainfile  = 'AssignCompanySegmentsPostgreSQL.R'
    when 'lifestage'
      r_directory = CORE_API_DIRECTORY + 'analysis-r/cluster-lifestage'
      r_mainfile  = 'Incremental_MLSM_via_PostgreSQL.R'
  end #case

  r_output    = "R_last_execution_output.txt"
  r_command   = sprintf( 'cd %s;  R CMD BATCH "--args db_hostname=\'%s\' db_username=\'%s\' db_password=\'%s\' db_database=\'%s\' db_port=\'%s\' company_id=\'%s\'" "%s" "%s"', r_directory, db_hostname, db_username, db_password, db_database, db_port, company_id, r_mainfile, r_output )
  r_result    = system( r_command )       # If R execution finishes successfully, result will be true

  return r_result
end #execute_local_r_code()

end #class AnalysisR


