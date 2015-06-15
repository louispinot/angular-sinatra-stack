(function(){
  'use strict';

  // angular.module('compass', ['ngRoute', 'angular-loading-bar', 'ngAnimate','ngResource', 'LocalStorageModule', 'ui.bootstrap'])
  //   .factory('$exceptionHandler', ['$log', function($log){
  //     return function (exception, cause) {
  //       logentriesSvc.javascriptError(exception, cause, $log);
  //     };
  //   }]);

  angular.module('compass').run(['$http','sessionService', 'userService', set_header]);

  function set_header($http, sessionService, userService){
    //   /!\ ca a priori on ca s'en reservir

    // var currentSession = sessionService.getCurrentSession();
    // if(currentSession){
    //   // get the user again if they already have a session. Prevents issues that result if we change the format of local storage.
    //   $http.defaults.headers.common['X-Api-SessionToken'] = currentSession.session_token;
    //   userService.getUser().then(function(user) {
    //     userService.setUser(user);
    //   });
    // }
  }

})();