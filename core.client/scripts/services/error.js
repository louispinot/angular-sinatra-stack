(function () {

  angular.module('compass') .factory('errorService', [errorSvc]);

  function errorSvc() {

    var service = {
      getErrorCode: getErrorCode,
      setErrorCode: setErrorCode
    };

    var errorCode = '';

    function setErrorCode(code){
      errorCode = code;
    }


    function getErrorCode() {
      return errorCode;
    }

     return service;
  }

})();