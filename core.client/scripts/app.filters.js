(function(){
  angular.module('compass').run(['$rootScope', '$location',  'loginService', auth_redirect]);
  angular.module('compass').run(['$rootScope', '$location',  'loginService', logout]);
  angular.module('compass').run(['$rootScope', set_layout_variable]);
  angular.module('compass').run(['$rootScope', "$location",  'loginService', 'userService', survey_redirect]);
  angular.module('compass').run(['$rootScope', "$location",  '$window', set_ga]);
  angular.module('compass').run(['$rootScope', 'alertService', clear_alerts]);

  function auth_redirect($rootScope, $location, loginService) {
    $rootScope.$on('$routeChangeStart', function (event, next) {
      if(!loginService.isAuthenticated() && next.authenticated) {
        loginService.logout();
        $location.path('/login');
      }
    });
  }

  function logout($rootScope, $location, loginService) {
    $rootScope.$on('$routeChangeStart', function (event, next) {
      if(next.logoutPage) {
        loginService.logout();
        $location.path('/login');
      }
    });
  }

  function survey_redirect($rootScope, $location, loginService, userService) {
    $rootScope.$on('$routeChangeStart', function (event, next) {

      if(next.errorPage){
        return;
      }

      if(loginService.isAuthenticated()){
        var surveyState = userService.getCurrentUser().survey_state;
        var lifestageState = userService.getCurrentUser().lifestage_state;

        if(['/settings', '/data_sources', '/connect_data_source', '/callback/google', '/callback/stripe', '/feedback', '/errors', '/terms', '/policy', '/monetization'].indexOf($location.path()) >= 0) {
          return;
        } else if (next.templateUrl==='views/dashboard.html' && lifestageState !== null){
          return;
        }

        if(surveyState !== 'clustering_complete'){
          // if the user hasn't finished the survey
          // Finds users current survey state vs the survey state they are attempting to navigate to.
          var possibleRoutes = ['monetization.html', 'users.html', 'customers.html', 'conversion.html', 'lifecycle.html', 'acquisition.html', 'revenue.html'];
          var nextIndex = possibleRoutes.indexOf(next.templateUrl.substr(next.templateUrl.lastIndexOf('/') + 1));
          var allowedIndex = possibleRoutes.indexOf(surveyState + '.html');

          if (next.isSurveyPage) {
            if(nextIndex > allowedIndex) {
              $location.path('/' + surveyState);
            }
          } else {
            $location.path('/' + surveyState);
          }
        }
        else {
          $location.path('/dashboard');
        }
      } // if(loginService.isAuthenticated())
    });
  }

  function set_layout_variable($rootScope) {
    $rootScope.$on('$routeChangeStart', function (event, next) {
      $rootScope.layout = next.layout;
    });
  }

  function set_ga($rootScope, $location, $window) {
    $rootScope.$on('$routeChangeStart',
      function() {
        $window.ga('send', 'pageview', { page: $location.url() });
      });
  }

  function clear_alerts($rootScope, alertService){
    $rootScope.$on('$routeChangeStart', function () {
      alertService.clear();
    });
  }
})();
