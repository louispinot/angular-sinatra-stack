(function () {
  'use strict';

  angular.module('habitac') .factory('auth',['$q', '$http', 'sessionService','loginService', 'userService', auth]);

  function auth($q, $http, sessionService, loginService, userService) {

    var service = {
      authenticate: authenticate
    };

    function authenticate(user) {

      var deferred = $q.defer();

      sessionService.createSession(user)
        .then(function(response){
          setSessionTokenHeader(response);
          sessionService.setCurrentSession(response);
          loginService.login();
          return userService.getUser();
        })
        .then(function(user){
          userService.setUser(user);
          return deferred.resolve(true);
        })
        .catch(function (error){
          deferred.reject(error);
        });

      return deferred.promise;
    }

    function setSessionTokenHeader(response){
      $http.defaults.headers.common['X-Api-SessionToken'] = response.session_token;
    }

    return service;
  }

})();