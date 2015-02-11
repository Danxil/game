'use sctrict'

class Controllers.ChooseCategoryController extends Controllers.BaseController
  @$inject = [
    '$scope'
    '$http'
    '$filter'
    '$timeout'
    '$location'
    '$baseUrl'
    '$rootScope'
    'categories'
  ]

  constructor: ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, categories) ->
    super($scope, $rootScope)
    $scope.chooseCategory = (category) ->
      if !category.active
        return

      $rootScope.choosenCategory = category

      $scope.goToChooseGame()

    for category in categories
      if !category.active
        category.title = "Coming soon"

    $scope.categories = categories

app.controller 'chooseCategoryCtrl', [
  '$scope'
  '$http'
  '$filter'
  '$timeout'
  '$location'
  '$baseUrl'
  '$rootScope'
  'categories'
  ($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, categories) ->
    new Controllers.ChooseCategoryController($scope, $http, $filter, $timeout, $location, $baseUrl, $rootScope, categories)
]
