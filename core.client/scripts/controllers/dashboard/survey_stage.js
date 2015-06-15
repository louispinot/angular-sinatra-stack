(function () {

  angular.module('compass').controller('StageCtrl', ['$rootScope', '$scope', '$resource', '$location', 'userService', 'alertService', stage]);

  function stage($rootScope, $scope, $resource, $location, userService, alertService) {

    $scope.displayWidget = displayWidget();
    $scope.whichSurveyHalf = whichSurveyHalf();
    $scope.submit_stage_widget = submit_stage_widget;
    $scope.payerHide = payerHide;
    $scope.userHide = userHide;

    function payerHide(){
      if (!userService.getCurrentUser().survey_answers.payer){
        return false;
      }else{
        return true;
      }
    }

    function userHide(){
      if (!userService.getCurrentUser().survey_answers.user){
        return false;
      }else{
        return true;
      }
    }

    function displayWidget(){
      var user = userService.getCurrentUser();
      if (user.lifestage_state === 'clustering_complete' || user.lifestage_state === 'lifestage_firstHalf') {
        return true;
      }
      if (user.lifestage_state === 'complete') {
        return false;
      }
    }

    function whichSurveyHalf(){
      var user = userService.getCurrentUser();

      if (user.lifestage_state === 'clustering_complete') {
        return 'firstHalf';
      }
      return 'secondHalf';
    }

    function submit_stage_widget(isValid, whichHalf){
      var stageResource = $resource('company/lifestage/:which_half');
      var user = userService.getCurrentUser();

      if (!isValid) {
        return;
      }

      stageResource.save({"which_half": whichHalf}, $scope.stage).$promise
        .then(function () {
          if (whichHalf ==='firstHalf') {
            user.lifestage_state = 'lifestage_firstHalf';
          } else {
            user.lifestage_state = 'complete';
            $scope.displayWidget = false;
          }
          userService.setUser(user);

          if(user.lifestage_state == 'complete') {
            $rootScope.$broadcast('surveyComplete');
          }

          $scope.whichSurveyHalf = whichSurveyHalf();

          $location.path('/dashboard');
        }) .catch(function () {
          user.survey_state = 'clustering_complete';
          userService.setUser(user);
          $scope.whichSurveyHalf = whichSurveyHalf();
          alertService.add( {
            type      : 'danger',
            msg       : 'There was a problem submitting.',
            redirects : 0
          } );
        });
    }
  }
})();
