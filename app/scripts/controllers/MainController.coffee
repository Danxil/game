'use strict'

class Controllers.MainController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$q'
    'AuthService'
    '$notificationService'
    '$orientation'
    '$controller'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, AuthService, $notificationService) ->
    super($scope, $rootScope)
    $scope.signInSubmit = ->
      delete $scope.signInError

      if !$scope.signInForm.$valid
        return $scope.signInError = true

      $rootScope.logoutAfterLogout = !$scope.signInData.remember

      AuthService.login($scope.signInData).then((userInfo) ->
        $rootScope.userData = userInfo
        if !$rootScope.redirectAfterLoginState
          $scope.goToLogged()
        else
          $rootScope.goToState $rootScope.redirectAfterLoginState
          delete $rootScope.redirectAfterLoginState
      (error) ->
        $scope.signInError = true
        $scope.signInData.password = ''
      )
    if $rootScope.userData
      $scope.userData = $rootScope.userData
      $scope.userData.printUserPosition = ->
        last_two_digits = (Math.abs(this.position) % 100)
        last_digit = (Math.abs(this.position) % 10)
        suffix = switch
          when last_digit == 1 and last_two_digits != 11 then "st"
          when last_digit == 2 and last_two_digits != 12 then "nd"
          when last_digit == 3 and last_two_digits != 13 then "rd"
          else "th"
        this.position + suffix

      noficationData = $notificationService.getBadgesNotifications()

      $q.when(noficationData).then(
        (result)->
          data = result.data

          $scope.badgeLander = data.hasOwnProperty('badge')

          $scope.notifications = data
        (error) ->
          $q.reject()
      )

      lastResult = localStorage.getItem('lastResult')
      if lastResult
        localStorage.removeItem('lastResult')
        lastResultData = $notificationService.getLastResult()
        $q.when(lastResultData).then(
          (result)->
            data = result.data

            $scope.lastResult = data.won != undefined
            $scope.lastResultData = data
          (error) ->
            $q.reject()
        )


app.controller 'mainCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$q'
  'AuthService'
  '$notificationService'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, AuthService, $notificationService) ->
    new Controllers.MainController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, AuthService, $notificationService)
]