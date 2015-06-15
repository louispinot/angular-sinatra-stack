(function () {
  'use strict';

  angular.module('compass').controller('SignupCtrl', ['$scope', '$location', "$analytics", 'userService', 'auth', 'alertService', signup]);

  function signup($scope, $location, $analytics, userService, auth, alertService) {
    $scope.signup = signup_submit;

    function signup_submit(user) {

      userService.createUser(user)
        .then(function(response){
          mixpanel.alias(response.user_id); // this links the MixpanelPeople generated UID with the user ID in our database
          return auth.authenticate(user);
        })
        .then(function(){
          var user = userService.getCurrentUser();
          $analytics.eventTrack('Signup', {email: user.email});

          $location.path('/connect_data_source');
        })
        .catch(function(response){
          alertService.add({type: 'danger', msg: response.data.message});
        });
    }

  }

})();
