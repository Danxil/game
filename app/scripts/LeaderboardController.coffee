'use strict'

controllers = angular.module('controllers', [])

class MainLeaderboardCtrl
  constructor:($scope, $http, $q, $location) ->
    @$http = $http
    @$q = $q
    @$scope = $scope
    @leaderBoardChanged = 0
    @$scope.activeList = undefined
    @moreUsersDisabled = true
    @currentPage = 1
    @$scope.leaderboard = []
    @moreUsersDisabled = true
    @getTop10()
    @$scope.getFrequentPlayers = ()=>
      @getFrequentPlayers()
    @$scope.getTop10 = ()=>
      @getTop10()
    @$scope.moreUsers = ()=>
      @moreUsers()

    websocket_server = "#{ $location.$$protocol }://#{ $location.$$host }:#{nodePort}"
    socket = io.connect(websocket_server, {'query': "token=leaderboard" })

    socket.on 'connect', () ->
      console.log('Client has connected to the server!')

    socket.on 'leaderboardchannel', (data) =>
      console.log('Received a leaderboard message from the server!', data)
      if data == "update"
        if @$scope.activeList == 0 then @getTop10() else  @getFrequentPlayers(@currentPage, @$scope.leaderboard.length, true)

    socket.on 'disconnect', () ->
      console.log('The client has disconnected!')

  moreUsers: ->
    if @$scope.activeList == undefined || @$scope.activeList == 0 || @moreUsersDisabled
      return

    @moreUsersDisabled = true
    @currentPage++
    @getFrequentPlayers(@currentPage)

  makeRequest: (params = {}) =>
    deferred = @$q.defer()
    @$http.get('/api/leaderboard/', params: params
    ).then((result) ->
      deferred.resolve(result.data)
    , (error) ->
        deferred.reject(error)
    )
    deferred.promise

  getFrequentPlayers: (page = 1, num = 10, update = false) ->
    params =
      frequent: '',
      page: page,
      num: num
    @$q.when(this.makeRequest(params)).then (data)=>
      @$scope.activeList = 1
      @moreUsersDisabled = data.length < 10
      if (page == 1 || update)
        @$scope.leaderboard = data
      else
        for item in data
          @$scope.leaderboard.push item

  getTop10: () ->
    @$q.when(this.makeRequest()).then (data)=>
      @$scope.leaderboard = data
      @$scope.activeList = 0
      @moreUsersDisabled = data.length < 10
      @currentPage = 1


controllers.controller('LeaderboardCtrl', [
  "$scope", '$http', '$filter', '$timeout', '$location', '$rootScope', '$q',
  ($scope, $http, $filter, $timeout, $location, $rootScope, $q)->
    new MainLeaderboardCtrl($scope, $http, $q, $location)
])