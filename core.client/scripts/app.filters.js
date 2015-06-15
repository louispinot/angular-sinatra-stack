(function(){
  angular.module('habitac').run(['$rootScope', '$location',  'loginService', auth_redirect]);
  angular.module('habitac').run(['$rootScope', '$location',  'loginService', logout]);
  angular.module('habitac').run(['$rootScope', set_layout_variable]);
  angular.module('habitac').run(['$rootScope', 'alertService', clear_alerts]);

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

  function set_layout_variable($rootScope) {
    $rootScope.$on('$routeChangeStart', function (event, next) {
      $rootScope.layout = next.layout;
    });
  }

  function clear_alerts($rootScope, alertService){
    $rootScope.$on('$routeChangeStart', function () {
      alertService.clear();
    });
  }
})();
