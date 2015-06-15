(function () {

  angular.module('compass').controller('SaasCallbackCtrl', ['$scope', '$resource', "$q", "$routeParams",'$window', 'alertService', 'userService', saasCallback]);

  function saasCallback ($scope, $resource, $q, $routeParams, $window, alertService, userService) {
    $scope.service = $routeParams.service;
    $scope.closeWindow = closeWindow;

    run($scope.service);
    function run(service) {
      if (service == "google"){
        var profilesResource = $resource('google/profiles');
        $scope.setGoogleProfile = setGoogleProfile;
        $scope.has_accounts = true;

        profilesResource.query().$promise
        .then(function(data){
          if (data.length === 0) {
            $scope.has_accounts = false;
            return;
          }
          $scope.accounts = data;
          $scope.account = data[0];
          $scope.web_property = $scope.account.web_properties[0];
          $scope.profile = $scope.web_property.profiles[0];
        })
        .catch(function(error){
          alertService.add({type: 'danger', msg: error.data.message});
          $scope.caughtError = true;
        });
      }

      if (service != "google"){
        var user = userService.getCurrentUser();
        user.data_connections.push(service.toUpperCase());
        asyncSetUser(user)
          .then(function(){
            $window.close();
          });
      }
    }


    function setGoogleProfile() {
      var profileResource = $resource('google/profile');
      var data = {"service_name":"google","data":{"profile_id":$scope.profile.id, "profile_name":$scope.profile.name}};
      profileResource.save(data).$promise
      .then(function(){
        var user = userService.getCurrentUser();
        user.data_connections.push('GOOGLE');
        asyncSetUser(user)
          .then(function(){
            $window.close();
          });
      });
    }

    function closeWindow() {
      $window.close();
    }

    function asyncSetUser(user) {
      // wraps the setUser method into a promise so that the window.close() in the `then` block only gets called AFTER the call to mixpanel has been made
      var deferred = $q.defer();
      if (userService.setUser(user)){
        deferred.resolve();
      } else{
        deferred.reject();
      }
      return deferred.promise;
    }
  }
})();


