'use strict'

class Controllers.ChooseGameController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $gameService) ->
    $scope.chooseGame = (game) ->
      if !game.unlocked
        return

      if $scope.choosenOpponent
        $gameService.checkUserAllow $scope.choosenOpponent.pk, game.pk
        .then (result)->
          data = result.data

          if !data.allow
            $rootScope.invalidOpponent = $scope.choosenOpponent
            if data.reason == "invited"
              $rootScope.invalidOpponentGameName = game.title

            return $scope.goToInvalidOpponent()

          $rootScope.choosenOpponent = $scope.choosenOpponent

          $rootScope.choosenGame = game

          $scope.goToGameLoading()
      else
        $rootScope.choosenGame = game

        $scope.goToChooseOpponent()

    $scope.games = undefined

    $http(
      url: '/api/game/',
      params:
        category: $rootScope.choosenCategory.id
    ).success (data, code) ->
      $scope.games = data

app.controller 'chooseGameCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$gameService'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $gameService) ->
    new Controllers.ChooseGameController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $gameService)
]