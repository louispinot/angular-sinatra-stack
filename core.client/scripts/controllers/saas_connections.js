(function () {
  'use strict';

  angular.module('compass').controller('saas_connectionsCtrl', ['$scope', '$resource','$window', 'userService',  saas_connect]);

  function saas_connect ($scope, $resource, $window, userService) {
    $scope.triggerPopup = triggerPopup;
    $scope.grayOut = false;
    $scope.connectedServices = userService.getCurrentUser().data_connections; //this needs to have an unless for a scope showing GA is attached.

    $resource('connection_urls').get().$promise
      .then(function(response){
        $scope.url = response.url;
        $scope.triggerPopup = triggerPopup;
      });

    function triggerPopup(service){
        $scope.grayOut = true;
        popupwindow(service, 500, 600);
    }

    function popupwindow(service, w, h) {
      var url = $scope.url[service];
      // Fixes dual-screen position                         Most browsers      Firefox
      var dualScreenLeft = window.screenLeft !== undefined ? window.screenLeft : screen.left;
      var dualScreenTop = window.screenTop !== undefined ? window.screenTop : screen.top;

      var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
      var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

      var left = ((width / 2) - (w / 2)) + dualScreenLeft;
      var top = ((height / 2) - (h / 2)) + dualScreenTop;
      var newWindow = $window.open(url, "Connection", 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
      document.getElementById("overlay-back").style.height=height + "px" ;

      var interval = window.setInterval(function() {
        try {
          if (newWindow === null || newWindow.closed) {
            $scope.grayOut = false;
            $scope.connectedServices = userService.getCurrentUser().data_connections;
            mixpanel.track("Data source connected", {A_source: service});
            window.clearInterval(interval);
            $scope.$apply();
          }
        }
        catch (e) {
        }
      }, 100);
      return newWindow;
    }

  }
})();
