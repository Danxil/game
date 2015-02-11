'use strict'

class Controllers.PendingChallengesController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    '$challengesService'
    '$q'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $challengesService, $q) ->
    super($scope, $rootScope)

    $scope.chooseList = (type)->
      return if $scope.in_progress

      $scope.in_progress = true
      $scope.challenges = []
      $rootScope.selectedList = $scope.selectedList = type

      $scope.currentPage = 1
      $scope.moreChallengesDisabled = true

      switch type
        when 0
          challenges = $challengesService.getPendingChallenges($scope.currentPage)
        when 1
          challenges = $challengesService.getSentChallenges($scope.currentPage)

      $q.when(challenges).finally(
        ()->
          $scope.in_progress = false
      ).then(
        (result)->
          data = result.data

          for item in data
            item.challenger_line_label = switch $scope.selectedList
              when 0
                switch
                  when item.challenger_position == 1 then '1'
                  when item.challenger_position <= 10 then 'Top 10'
              when 1
                switch
                  when item.challenged_position == 1 then '1'
                  when item.challenged_position <= 10 then 'Top 10'

          $scope.moreChallengesDisabled = data.length < 10

          $scope.challenges = data

          $rootScope.activeList = $scope.activeList = type
        (error) ->
          $q.reject()
      )

    $scope.moreChallenges = ->
      if $scope.activeList == undefined || $scope.moreChallengesDisabled
        return

      $scope.in_progress = true

      $scope.moreChallengesDisabled = true

      $scope.currentPage++

      switch $scope.selectedList
        when 0
          challenges = $challengesService.getPendingChallenges($scope.currentPage)
        when 1
          challenges = $challengesService.getSentChallenges($scope.currentPage)

      $q.when(challenges).finally(
        ()->
          $scope.in_progress = false
      ).then(
        (result)->
          data = result.data

          for item in data
            item.challenger_line_label = switch $scope.selectedList
              when 0
                switch
                  when item.challenger_position == 1 then '1'
                  when item.challenger_position <= 10 then 'Top 10'
              when 1
                switch
                  when item.challenged_position == 1 then '1'
                  when item.challenged_position <= 10 then 'Top 10'
            $scope.challenges.push item

          $scope.moreChallengesDisabled = data.length < 10
        (error) ->
          $q.reject()
      )

    $scope.acceptChallenge = (challenge)->
      if $rootScope.gameProcess then return

      $http.get '/api/game/' + challenge.game_pk + '/questions/', params: {"challenge": challenge.pk}
      .error ()->
        $scope.goToLogged()

      $rootScope.choosenChallenger =
        avatar: challenge.challenger_image
        username: challenge.challenger_name
        correct_answers: challenge.correct_answers
        time: challenge.game_time
        challenge_id: challenge.pk

      $scope.goToGameLoading
        pk: challenge.game_pk
        icon: challenge.game_icon
        title: challenge.game_title
        points: challenge.game_points
        game_type: challenge.game_type
        first_play: challenge.first_play
        asset_title: challenge.game_asset_title
        asset_link: challenge.game_asset_link

    $scope.chooseList(0)
    $rootScope.chooseList = $scope.chooseList;
    $scope.$on '$destroy', ->
      delete $rootScope.selectedList

app.controller 'pendingChallengesCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  '$challengesService'
  '$q'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $challengesService, $q) ->
    new Controllers.PendingChallengesController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, $challengesService, $q)
]