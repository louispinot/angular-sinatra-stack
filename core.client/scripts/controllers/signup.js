(function () {
  'use strict';

  angular.module('habitac').controller('SignupCtrl', ['$scope', '$location', 'userService', 'auth', 'alertService', signup]);

  function signup($scope, $location, userService, auth, alertService) {
    $scope.signup = signup_submit;

    function signup_submit(user) {

      userService.createUser(user)
        .then(function(response){
          return auth.authenticate(user);
        })
        .then(function(){
          var user = userService.getCurrentUser();

          $location.path('/connect_data_source');
        })
        .catch(function(response){
          alertService.add({type: 'danger', msg: response.data.message});
        });
    }

  }

})();
