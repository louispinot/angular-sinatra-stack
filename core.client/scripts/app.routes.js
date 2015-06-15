(function() {
  angular.module('habitac').config([
    '$locationProvider',
    '$routeProvider',
    function($locationProvider, $routeProvider) {

      $routeProvider
        .when('/', {
          templateUrl: 'views/main.html',
          authenticated: false,
          layout: "landing"
        })
        .otherwise({
          redirectTo: '/',
          authenticated: true,
          layout: "application"
        });

      $locationProvider.html5Mode(true);
    }
  ]);
})();