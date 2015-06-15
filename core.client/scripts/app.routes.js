(function() {
  angular.module('compass').config([
    '$locationProvider',
    '$routeProvider',
    function($locationProvider, $routeProvider) {

      $routeProvider
        .when('/', {
          templateUrl: 'views/main.html',
          authenticated: false,
          layout: "landing"
        })
        .when('/login', {
          templateUrl: 'views/login.html',
          authenticated: false,
          layout: "login"
        })
        .when('/change_password/:resetToken', {
          templateUrl: 'views/change_password.html',
          authenticated: false,
          controller: "ResetCtrl",
          layout: "login"
        })
        .when('/signup', {
          templateUrl: 'views/signup.html',
          authenticated: false,
          layout: "login"
        })
        .when('/reset', {
          templateUrl: 'views/reset.html',
          authenticated: false,
          layout: "login"
        })
        .when('/connect_data_source', { // this is the one that appears before the survey
          templateUrl: 'views/connect_data_source.html',
          authenticated: true,
          layout: "survey"
        })
        .when('/monetization', {
          templateUrl: 'views/survey/monetization.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/users', {
          templateUrl: 'views/survey/users.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/customers', {
          templateUrl: 'views/survey/customers.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/conversion', {
          templateUrl: 'views/survey/conversion.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/lifecycle', {
          templateUrl: 'views/survey/lifecycle.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/acquisition', {
          templateUrl: 'views/survey/acquisition.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/revenue', {
          templateUrl: 'views/survey/revenue.html',
          authenticated: false,
          layout: "survey",
          isSurveyPage: true
        })
        .when('/dashboard', {
          templateUrl: 'views/dashboard.html',
          authenticated: true,
          layout: "application"
        })
        .when('/settings', {
          templateUrl: 'views/settings.html',
          authenticated: true,
          layout: "application"
        })
        .when('/data_sources', {
          templateUrl: 'views/data_sources.html',
          authenticated: true,
          layout: "application"
        })
        .when('/feedback', {
          templateUrl: 'views/feedback.html',
          authenticated: true,
          layout: "application"
        })
        .when('/terms', {
          templateUrl: 'views/terms.html',
          authenticated: false,
          layout: "bareLogo"
        })
        .when('/policy', {
          templateUrl: 'views/policy.html',
          authenticated: false,
          layout: "bareLogo"
        }).
        when('/callback/:service', {
          templateUrl: function(urlAttr){
            if (urlAttr.service == 'google') {
              return 'views/google_callback.html';
            } else {
              return 'views/generic_callback.html';
            }
          },
          controller: "SaasCallbackCtrl",
          authenticate: true,
          layout: "bareLogo"
        }).
        when('/error', {
          templateUrl: 'views/error.html',
          authenticate: false,
          errorPage: true
        }).
        when('/logout', {
          authenticate: false,
          logoutPage: true
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