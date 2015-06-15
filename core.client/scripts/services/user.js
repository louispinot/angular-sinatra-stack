(function () {

  angular.module('compass') .factory('userService', ['$resource', 'localStorageService',  user]);

  function user($resource, localStorageService) {

    var service = {
      createUser: createUser,
      getUser: getUser,
      getCurrentUser: getCurrentUser,
      setUser: setUser,
      resetPassword: resetPassword,
      updateUser: updateUser,
      updatePassword: updatePassword
    };

    function createUser(user) {
      var userResource = $resource('users');
      return userResource.save(user).$promise;
    }

    function getUser(){
        var userResource = $resource('users');
        return userResource.get().$promise;
    }

    function updateUser(user, password){
        return $resource('/users/update_user').save({newUser: user, newPass: (password ? password : null)}).$promise;
    }

    function getCurrentUser() {
      return localStorageService.get('user');
    }

    function setUser(user){
      // hack leveraging the JSON library to clone the user object. That way mixpanelUser is NOT a reference to the original user object
      var mixpanelUser = (JSON.parse(JSON.stringify(user)));
      delete(mixpanelUser.email);
      delete(mixpanelUser.phone_number);
      mixpanelUser.$email = user.email;
      mixpanelUser.$phone = user.phone_number;

      mixpanel.people.set(mixpanelUser);
      mixpanel.identify(mixpanelUser.id);

      return localStorageService.set('user', user);
    }

    function resetPassword(email){
      var userResource = $resource('/users/reset_password');
      return userResource.save({"email": email}).$promise;
    }

    function updatePassword(token, newPassword){
      var userResource = $resource('/users/update_password');
      return userResource.save({reset_token: token, password: newPassword}).$promise;
    }

    return service;
  }

})();