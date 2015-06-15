(function(){
  'use strict';

  angular.module('compass', ['ngRoute', 'angular-loading-bar', 'ngAnimate','ngResource', 'LocalStorageModule', 'ui.bootstrap', 'dibari.angular-ellipsis', 'angulartics', 'angulartics.mixpanel'])
    .factory('$exceptionHandler', ['$log', 'logentriesSvc', function($log, logentriesSvc){
      return function (exception, cause) {
        logentriesSvc.javascriptError(exception, cause, $log);
      };
    }]);

  angular.module('compass').run(['$http','sessionService', 'userService', set_header]);

  function set_header($http, sessionService, userService){
    var currentSession = sessionService.getCurrentSession();

    if(currentSession){
      // get the user again if they already have a session. Prevents issues that result if we change the format of local storage.
      $http.defaults.headers.common['X-Api-SessionToken'] = currentSession.session_token;
      userService.getUser().then(function(user) {
        userService.setUser(user);
      });
    }
  }

})();