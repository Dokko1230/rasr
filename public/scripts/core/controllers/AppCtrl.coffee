app.controller "AppCtrl", ($scope, $location) ->

app.factory 'authInterceptor', ($rootScope, $q, $window) ->
  return {
    request: (config) ->
      config.headers = config.headers || {};
      console.log("yo")
      if $window.localStorage.userToken
        console.log("testing")
        config.headers.Authorization = $window.localStorage.userToken
      return config
    response: (response) ->
      if response.status is 401
        console.log('token deleted')
      return response || $q.when(response)
  }

# Intercept 401s and redirect you to login
app.config(($stateProvider, $locationProvider, $httpProvider, $urlRouterProvider) ->
  $httpProvider.interceptors.push('authInterceptor')
  # $httpProvider.interceptors.push [
  #   "authInterceptor"
  #   "$q"
  #   "$location"
  #   ($q, $location) ->
  #     return responseError: (response) ->
  #       if response.status is 401
  #         $location.path "/login"
  #         $q.reject response
  #       else
  #         $q.reject response
  # ]
  return
).run ($rootScope, $location, Auth) ->
  
  # Redirect to login if route requires auth and you're not logged in
  $rootScope.$on "$stateChangeStart", (event, next) ->
    
    # if($location.path() === '/play') {
    #   if(window.game) {
    #     window.game.paused = false;
    #   }
    # } else {
    #   if(window.game) {
    #     window.game.paused = true;
    #   }
    # }
    $location.path "/login" if next.authenticate and not Auth.isLoggedIn()
    return

  return

