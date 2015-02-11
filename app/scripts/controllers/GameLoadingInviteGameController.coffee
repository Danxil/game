'use strict'

class Controllers.GameLoadingInviteGameController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$randomValue'
    '$controller'
    '$stateParams'
    '$gameService'
    '$q'
    'game'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, game) ->
    $rootScope.choosenGame = game
    $rootScope.choosenCategory =
      title: game.meta_category
      id: game.meta_category_id

    $rootScope.goToChooseOpponent()

app.controller 'gameLoadingInviteGameCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$randomValue'
  '$controller'
  '$stateParams'
  '$gameService'
  '$q'
  'game'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, game) ->
    new Controllers.GameLoadingInviteGameController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $randomValue, $controller, $stateParams, $gameService, $q, game)
]
