'use strict'

class Controllers.GameLoseController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$timeout'
    '$rootScope'
  ]

  constructor: ($scope, $timeout, $rootScope) ->
    $timeout ->
      if $rootScope.stateStorage.app.state.name == 'root.app.game.game-lose-1'
        $scope.goToGameLose2()
    , 2500

app.controller 'gameLose1Ctrl', [
  '$scope'
  '$timeout'
  '$rootScope'
  ($scope, $timeout, $rootScope) ->
    new Controllers.GameLoseController($scope, $timeout, $rootScope)
]