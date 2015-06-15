(function() {
  'use strict';

  angular.module('habitac').factory('sessionService',['$resource', 'localStorageService', sessionSvc]);

  function sessionSvc ($resource, localStorageService) {
    var service = {
      createSession: createSession,
      getCurrentSession: getCurrentSession,
      setCurrentSession: setCurrentSession
    };

    function createSession(user) {
      var sessionResource = $resource('sessions');
      return sessionResource.save(user).$promise;
    }

    function getCurrentSession() {
      return angular.fromJson(localStorageService.get('session'));
    }

    function setCurrentSession(session) {
      localStorageService.add('session', angular.toJson(session));
    }

    return service;
  }

})();