(function () {
  'use strict';

  angular.module('habitac')
  .factory('loginService', ['$rootScope', 'sessionService', 'localStorageService', loginSvc]);

  function loginSvc ($rootScope, sessionService, localStorageService) {

    function login () {
      $rootScope.isAuthenticated = true;
    }

    function logout () {
      localStorageService.clearAll();
      $rootScope.isAuthenticated = false;
    }

    function isAuthenticated () {
      if(sessionService.getCurrentSession()) {
        return true;
      }
      return false;
    }

    return {
      login: login,
      logout: logout,
      isAuthenticated: isAuthenticated
    };
  }

})();