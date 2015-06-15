// (function() {

//   angular.module('habitac').config(['$httpProvider', function($httpProvider) {

//     $httpProvider.interceptors.push(['$q', 'errorService', '$location', 'localStorageService', globalErrorsConfig]);

//     function globalErrorsConfig($q, errorService, $location, localStorageService) {
//       return {
//         'responseError': function(response) {
//           errorService.setErrorCode(response.status);
//           var user = localStorageService.get('user') || null;
//           //due to circular reference I have to be explicit with $location and user

//           switch (response.status) {
//             case 0:
//               break;
//             case 401:
//               localStorageService.clearAll();
//               $location.path('/login');
//               return $q.reject(response);
//             case 403:
//               return $q.reject(response);
//             case 409:
//               return $q.reject(response);
//             case 500:
//               break;
//             default:
//           }

//           $location.path('/error');

//           return $q.reject(response);
//         }
//       };
//     }
//   }]);
// })();

