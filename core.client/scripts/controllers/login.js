(function () {
  'use strict';

  angular.module('habitac').controller('LoginCtrl', ['$scope', '$location', 'auth', "userService", 'alertService', login]);

  function login ($scope, $location, auth, userService, alertService) {
    $scope.authenticate = authenticate;

    function authenticate () {

      auth.authenticate($scope.user)
        .then(function(isAuthenticated){
          if(isAuthenticated) {
            var user = userService.getCurrentUser();
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