create_lifestage = lambda do
  unless params[:which_half]
    return 400
  end

  lifestage = JSON.parse(request.body.read, :symbolize_names => true)
  user = current_user

  if params[:which_half] == "firstHalf"
    user.company.lifestages.create(users: lifestage[:users],
                                   payers: lifestage[:payers],
                                   employees: lifestage[:employees],
                                   engineers: lifestage[:engineers]
      )
  end


  if params[:which_half] == "secondHalf"
    if update_lifestage?(user) == :reject
      # user.update(survey_state: 'clustering_complete') #needs to be changed because it will break if it is hit
      return 500, {survey_state: 'clustering_complete'}.to_json
    end

    user.company.lifestages.last.update_attributes(
                  revenue_last_month: lifestage[:revenue],
                  expenses_last_month: lifestage[:expenses],
                  customer_lifetime: lifestage[:lifetime]
      )


    ### (Analysis R) LIFESTAGE-CLUSTERING ##########################################################
    r_result    = AnalysisR.lifestage_cluster

    # if result != true, the execution exited with an error-code != 0 (false) or failed completely (nil)
    if ! r_result
      printf "There was an error executing the (lifestage-cluster) Analysis R code: %s (%s)\n", $?, r_result.inspect    # $? will hold the bash-error-code in case of an execution-error
      status 500
    end
  end #if "secondHalf"
end

post '/company/lifestage/:which_half', requires_authentication: true, &create_lifestage



def update_lifestage?(user)
  current_lifestage = user.company.lifestages.last
  unless current_lifestage.revenue_last_month.nil? &&
    current_lifestage.expenses_last_month.nil? &&
    current_lifestage.customer_lifetime.nil?
    return :reject
  else
  end
end