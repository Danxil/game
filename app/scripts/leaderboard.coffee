'use strict'

app = angular.module("leaderboard",
[
  'ui.router'
  'infinite-scroll'
  'controllers'
])

app.config [
  "$stateProvider"
  ($stateProvider) ->
    $stateProvider
      .state("home", {
        url: "^",
        controller: "LeaderboardCtrl",
        templateUrl: "/views/leaderboard-single.html"
      })
]