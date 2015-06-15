(function () {
  'use strict';

  angular.module('compass').controller('AdminCtrl', ['$scope', '$resource', '$http', 'alertService', 'sessionService', 'loginService', 'userService', admin]);

  function admin ($scope, $resource, $http, alertService, sessionService, loginService, userService) {
    $scope.isAdmin = userService.getCurrentUser().is_admin;
    $scope.loginAs = loginAs;
    $scope.user = {email: null};

    function loginAs() {
      $resource('/login_as/:user_id').get({user_id: $scope.user.id}).$promise
        .then(function(response){
          $http.defaults.headers.common['X-Api-SessionToken'] = response.session_token;
          sessionService.setCurrentSession(response);
          loginService.login();
          return userService.getUser();
        })
        .then(function(user){
          userService.setUser(user);
          window.location.href = '/dashboard';
        })
        .catch(function(response){
          alertService.add( {
            type      : 'danger',
            msg       : response.data.message,
            redirects : 1
          } );
        });
    } // loginAs
  }

})();