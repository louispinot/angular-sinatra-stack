(function () {
  'use strict';

  angular.module('compass').controller('SurveyClusteringCtrl', ['$scope','$location','$resource', 'alertService', 'localStorageService', 'userService', "sessionService", survey_ctrl]);

  function survey_ctrl($scope, $location, $resource, alertService, localStorageService, userService, sessionService) {

    $scope.currentStep = $location.path().slice(1);
    $scope.steps = ['monetization', 'users', 'customers', 'conversion', 'lifecycle', 'acquisition', 'revenue'];
    $scope.send_form = send_form;
    $scope.surveyNavButton = surveyNavButton;
    $scope.surveyIndex = ($scope.steps.indexOf(userService.getCurrentUser().survey_state)+1); //correctly populates the gray nav buttons if they have been completed
    $scope.model = userService.getCurrentUser().survey_answers;


    //allows navigation by right hand survey buttons, checks to see is /users or /customers was skipped in monetization question
    function surveyNavButton(step){
      if(step === 'users' || step === 'customers') {
        if(localStorageService.get('skip') === 'customers' || userService.getCurrentUser().survey_answers.monetiz === 'monetiz_indirect_standard') {
          $location.path('/users');
        }else if(localStorageService.get('skip') === 'users' || userService.getCurrentUser().survey_answers.monetiz === 'monetiz_direct_standard'){
          $location.path('/customers');
        }else{
          $location.path("/" + step);
        }
      }else{
        $location.path("/" + step);
      }
    }

    function send_form(form, current_question, next_question) {
      //monetiz_direct_standard skips '/users' ::: monetiz_indirect_standard skips '/customers'
      if($scope.model.monetiz === 'monetiz_direct_standard'){
        localStorageService.add('skip', 'users');
      }else if($scope.model.monetiz === 'monetiz_indirect_standard'){
        localStorageService.add('skip', 'customers');
      }else if($scope.model.monetiz === 'monetiz_direct_freemium'){
        localStorageService.remove('skip');
      }else if($scope.model.monetiz === 'monetiz_indirect_two_sided'){
        localStorageService.remove('skip');
      }

      mixpanel.track(current_question, {A_answer: answer(current_question)});

      if(next_question === 'users'){
        if(localStorageService.get('skip') === 'users'){
          mixpanel.track('users', {A_answer: "skipped"});
          next_question = 'customers';
        }
      }

      if(current_question === 'users'){
        if(localStorageService.get('skip') === 'customers'){
          mixpanel.track('customers', {A_answer: "skipped"});
          next_question = 'conversion';
        }
      } //end of skipping user or customer question

      if (form.$invalid) {
        alertService.add( {
          type      : 'danger',
          msg       : 'Please answer all questions.',
          redirects : 0
        } );
        return;
      }


      //revises the hash brought in from the back end to allow blue highlighting to persist
      var answers = $scope.model || {};
      answers[Object.keys($scope.model)] = $scope.model[Object.keys($scope.model)];

      var companyResource = $resource('company/' + current_question);
      companyResource.save($scope.model).$promise
      .then(function() {
        var user = userService.getCurrentUser();
        if (next_question === "dashboard") {
          userService.getUser()
          .then(function(responseUser){
            userService.setUser(responseUser);
            $location.path('/dashboard');
          });
        } else {
          if($scope.steps.indexOf(user.survey_state) <= $scope.steps.indexOf(next_question)) {
            user.survey_state = next_question;
          }
          user.survey_answers = answers;
          userService.setUser(user);
        }

        $location.path(next_question);

      }).catch(function() {

        alertService.add({
          type      : 'danger',
          msg       : 'There was a problem submitting.',
          redirects : 0
        });

      });
    } // send_form()

    function answer(question){
      var questionsToModel = {
        acquisition: "acquisition_channel",
        customers: "payer",
        lifecycle: "lifecycle",
        monetization: "monetiz",
        revenue: "revenue_channel",
        users: "user"
      };
      if (question == "conversion") {
        var conversion = [];
        angular.forEach($scope.model, function(value, key){
          if (key.substr(0,5) == "conv_" && value === true) {
            conversion.push(key);
          }
        });
        return conversion;
      } else {
        return $scope.model[questionsToModel[question]];
      }
    }
  }

})();