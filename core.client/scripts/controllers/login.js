(function () {
  'use strict';

  angular.module('compass').controller('LoginCtrl', ['$scope', '$location', "$analytics", 'auth', "userService", 'alertService', login]);

  function login ($scope, $location, $analytics, auth, userService, alertService) {
    $scope.authenticate = authenticate;

    function authenticate () {

      auth.authenticate($scope.user)
        .then(function(isAuthenticated){
          if(isAuthenticated) {
            var user = userService.getCurrentUser();
            $analytics.eventTrack('Login', {email: user.email});
            if(user.lifestage_state !== 'clustering_complete' && user.lifestage_state !== 'lifestage_firstHalf' && user.lifestage_state !== 'complete'){
              if(user.data_connections.length === 0 ){
                $location.path('/connect_data_source');
              } else {
                $location.path('/' + user.survey_state);
              }
            } else {
              $location.path('/dashboard');
            }
          }
        }).catch(function(error){
          alertService.add({type: 'danger', msg: error.data.message});
        });

    }
  }

})();