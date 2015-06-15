(function () {
  'use strict';

  angular.module('compass').controller('SettingsCtrl', ['$scope', '$location', 'alertService', 'userService', settings]);

  function settings ($scope, $location, alertService, userService) {
    $scope.submitSettingsForm = submitSettingsForm;
    $scope.cancel = cancel;
    $scope.user = userService.getCurrentUser(); //changes based on form
    $scope.current_email = userService.getCurrentUser().email; //stays original email regardless of form

    function submitSettingsForm () {
      var newPassword = null;
      if ($scope.user.password && $scope.user.password.length !== 0) {
        newPassword = $scope.user.password;
      }

      delete($scope.user.password); // so as not to save the password in localStorage


      userService.updateUser($scope.user, newPassword)
        .then(function() {
          alertService.add({type: 'success', msg: 'Your profile information has been updated.'});
        }).catch(function(error){
          $scope.user.email = $scope.current_email; //if email already existed, keep original email in the scope
          alertService.add({type: 'danger', msg: error.data.message});
        }).then(function(){
          userService.setUser($scope.user);
        });

    }

    function cancel () {
      $location.path('/');
    }
  }

})();