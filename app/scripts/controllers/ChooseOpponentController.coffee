'use strict'

class Controllers.ChooseOpponentController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$q'
    'LeaderBoardService'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, LeaderBoardService) ->
    super($scope, $rootScope)

    $scope.activeList = undefined

    $scope.chooseList = (type)->
      if type == $scope.activeList
        return

      $scope.selectedList = type

      $scope.currentPage = 1
      $scope.moreUsersDisabled = true

      switch type
        when 0
          $rootScope.Opponents = -> LeaderBoardService.getTop10()
        when 1
          $rootScope.Opponents = -> LeaderBoardService.getFrequentPlayers($scope.currentPage)
        when 2
          $rootScope.Opponents = -> LeaderBoardService.getFriends($scope.currentPage)

      $q.when($rootScope.Opponents()).then (data)->
        $scope.opponents = data
        $scope.activeList = type

        $scope.moreUsersDisabled = data.length < 10

    $scope.moreUsers = ->
      if $scope.activeList == undefined || $scope.activeList == 0 || $scope.moreUsersDisabled
        return

      $scope.moreUsersDisabled = true

      $scope.currentPage++

      switch $scope.selectedList
        when 0
          Opponents = -> LeaderBoardService.getTop10($scope.currentPage)
        when 1
          Opponents = -> LeaderBoardService.getFrequentPlayers($scope.currentPage)
        when 2
          Opponents = -> LeaderBoardService.getFriends($scope.currentPage)

      $q.when(Opponents()).then (data)->
        for item in data
          $scope.opponents.push item

        $scope.moreUsersDisabled = data.length < 10

    $scope.playWithComputer = ->
      $scope.goToGameLoading()

    $scope.chooseList 0

    $scope.$watch 'leaderboardUpdate', (newVal)->
      if !newVal
        return

      $q.when($rootScope.Opponents()).then (data)->
        $scope.currentPage = 1

        $scope.opponents = data

    $http(
      url: '/api/game/',
      params:
        category: $rootScope.choosenCategory.id
    ).success (data, code) ->
      $scope.games = data

app.controller 'chooseOpponentCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$q'
  'LeaderBoardService'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, LeaderBoardService) ->
    new Controllers.ChooseOpponentController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, LeaderBoardService)
]