"use strict"
window.app = app = angular.module("komApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "ui.router"
])
app.constant "SERVER_URL", "http://localhost:3000"
app.constant "GET_SCREEN", "/api/screen" # api/screen/:screenId
app.constant "MOVE_SCREEN", "/api/screen/move" # api/screen/move/:direction/:currentScreenId
app.constant "MAKE_SCREEN", "/api/screen/make" # api/screen/move/:direction/:currentScreenId
app.constant "GET_SESSION", "/api/session"

app.config(['$httpProvider', ($httpProvider) -> 
  $httpProvider.defaults.useXDomain = true # Enable cross domain calls
  delete $httpProvider.defaults.headers.common['X-Requested-With']
  # Remove the header used to identify ajax call that would prevent CORS from working
  # http://thibaultdenizet.com/tutorial/cors-with-angular-js-and-sinatra/
])
