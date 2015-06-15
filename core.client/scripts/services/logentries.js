(function() {
  'use strict';

  angular.module('compass').factory('logentriesSvc',[logentriesSvc]);

  function logentriesSvc () {
    var hostname =  window.location.hostname;
    var logentries = {
      htmlError: htmlError,
      javascriptError: javascriptError
    };

    //initiate logentries, only if the browser is loaded/refreshed
    if (hostname === 'beta.compass.co') {
      LE.init('2ee95452-a1b8-4760-980f-a095d0c95330');
    } else if (hostname === 'www.compass.co') {
      LE.init('6502baed-d677-422f-ac8b-5c6e8e4be202');
    }

    function htmlError(response, location, user) {
      var message = 'HTTP Error ' + response.status + ': ' + response.data.message + ' Location: ' + location + '. Email: ' + (user ? user.email : 'none') ;
      if(hostname === 'beta.compass.co' || hostname === 'www.compass.co'){ //log clean error message based on location
        LE.log(message);
        mixpanel.track( "ErrorPage", { "A_code" : response.status, "A_message" : response.data.message, "A_location" : location, "A_email" : (user ? user.email : 'none') } ); //the A_ is to separate our hash keys from mixpanel methods
      }else{
        console.log(message); //spits out the error in console
      }
    }

    function javascriptError(exception, cause, $log) {//$log needs to be pulled from the exception handler factory
      exception.message += ' (cause: "' + cause + '" location: ' + window.location.href + ')';
      if(hostname === 'beta.compass.co'){ //log clean error message based on location
        LE.log(exception.message);
        throw exception; //throws error with exception, but without a stack trace
      }else if(hostname === 'www.compass.co'){
        LE.log(exception.message);
      }else{
        $log.error.apply($log, arguments); //this shows us the normal error logging, with a stack trace
      }
    }

    return logentries;
  }

})();