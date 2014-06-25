(function() {
  app.controller("AppCtrl", function($scope, $location) {});

  app.factory('authInterceptor', function($rootScope, $q, $window) {
    return {
      request: function(config) {
        config.headers = config.headers || {};
        console.log("yo");
        if ($window.localStorage.userToken) {
          console.log("testing");
          config.headers.Authorization = $window.localStorage.userToken;
        }
        return config;
      },
      response: function(response) {
        if (response.status === 401) {
          console.log('token deleted');
        }
        return response || $q.when(response);
      }
    };
  });

  app.config(function($stateProvider, $locationProvider, $httpProvider, $urlRouterProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  }).run(function($rootScope, $location, Auth) {
    $rootScope.$on("$stateChangeStart", function(event, next) {
      if (next.authenticate && !Auth.isLoggedIn()) {
        $location.path("/login");
      }
    });
  });

}).call(this);
