(function () {
  'use strict';

  angular.module('habitac').controller( 'ResetCtrl', ["auth", "$routeParams",'$scope', '$location', 'alertService', "userService", reset]);

  function reset(auth, $routeParams, $scope, $location, alertService, userService) {
    $scope.send_reset = send_reset;
    $scope.change_pwd = change_pwd;

    function send_reset(email) {
      console.log(email);
      userService.resetPassword(email)
        .then(function(){
          alertService.add({
            type: 'info',
            msg: 'Password reset email sent.',
            redirects: 0
          });
        })
        .catch(function(){
          alertService.add({
            type: 'danger',
            msg: 'No user was found with this email address',
            redirects: 0
          });
        });
      $location.path('/login');
    }

    function change_pwd(newPassword){
      userService.updatePassword($routeParams.resetToken, newPassword)
        .then(function(response){
          var user = {email: response.email, password: newPassword};
          return auth.authenticate(user);
        })
        .then(function(){
          alertService.add( {
            type      : 'info',
            msg       : 'Your password has been modified.',
            redirects : 1
          } );
          $location.path('/cluster');
        })
        .catch(function(response){
          alertService.add( {
            type      : 'danger',
            msg       : 'Your reset link has been compromised. Please submit a new reset request',
            redirects : 1
          } );
          $location.path('/reset');
        });
    }
  }
})();
