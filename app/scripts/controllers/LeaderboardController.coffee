'use strict'

class Controllers.LeaderboardController extends Controllers.BaseController
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

    $rootScope.leaderBoardChanged = 0
    $scope.activeList = undefined

    $scope.chooseList = (type)->
      if type == $scope.activeList
        return

      $scope.selectedList = type

      $scope.currentPage = 1
      $scope.moreUsersDisabled = true

      switch type
        when 0
          $rootScope.Leaderboard = -> LeaderBoardService.getTop10()
        when 1
          $rootScope.Leaderboard = -> LeaderBoardService.getFrequentPlayers($scope.currentPage)
        when 2
          $rootScope.Leaderboard = -> LeaderBoardService.getFriends($scope.currentPage)

      $q.when($rootScope.Leaderboard()).then (data)->
        $scope.leaderboard = data
        $scope.activeList = type

        $scope.moreUsersDisabled = data.length < 10

    $scope.moreUsers = ->
      if $scope.activeList == undefined || $scope.activeList == 0 || $scope.moreUsersDisabled
        return

      $scope.moreUsersDisabled = true

      $scope.currentPage++

      switch $scope.selectedList
        when 0
          Leaderboard = -> LeaderBoardService.getTop10($scope.currentPage)
        when 1
          Leaderboard = -> LeaderBoardService.getFrequentPlayers($scope.currentPage)
        when 2
          Leaderboard = -> LeaderBoardService.getFriends($scope.currentPage)

      $q.when(Leaderboard()).then (data)->
        for item in data
          $scope.leaderboard.push item

        $scope.moreUsersDisabled = data.length < 10

    $scope.$watch 'leaderboardUpdate', (newVal)->
      if !newVal
        return

      $q.when($rootScope.Leaderboard()).then (data)->
        $scope.currentPage = 1

        $scope.leaderboard = data

    $scope.chooseList 0

app.controller 'leaderboardCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$q'
  'LeaderBoardService'
  '$controller'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, LeaderBoardService) ->
    new Controllers.LeaderboardController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $q, LeaderBoardService)
]