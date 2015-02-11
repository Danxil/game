'use strict';

directives = angular.module("directives", [])

directives.directive "stopProp", ->
  ($scope, elem, attrs) ->
    elem.bind attrs.stopProp, (e) ->
      e.stopPropagation()
      return

    return

directives.directive "uniform", ->
  ($scope, elem, attrs) ->
    elem = $ elem[0]

    elem.uniform()

    return

directives.directive "chosen", ->
  restrict: 'A'
  scope: true
  require: '?ngModel'
  link: ($scope, elem, attrs, ngModel) ->
    elem.chosen
      disable_search_threshold: 10
      width: '100%'
    .change ->
      angular.element(elem[0]).triggerHandler 'blur'
    .bind 'DOMNodeInserted', ->
      elem.trigger 'chosen:updated'

    return

directives.directive 'chosenUpdate', [
  '$timeout'
  ($timeout)->
    restrict: 'A'
    scope: true
    require: '?ngModel'
    link: ($scope, elem, attrs) ->
      return
      if (eval attrs.chosenUpdate) then $timeout ->
        elem.parent('select').chosen
          disable_search_threshold: 10
          width: '100%'
        .change ->
          ngModel.$setViewValue(elem.val());
          angular.element(elem[0]).triggerHandler 'blur'
]

directives.directive "errorAutofocus", ->
  ($scope, elem, attrs) ->
    $scope.$watchCollection 'registrationData.error', (newValue)->
      if !newValue
        return

      setTimeout ()->
        currElem = $('form .input-wrapper.error:first')
        if currElem.length
          currElem.find('input').focus()

          $('html, body').animate
            scrollTop: currElem.offset().top - 30

    return

app.directive "slider", [
  "$rootScope"
  "$timeout"
  '$orientation'
  ($rootScope, $timeout, $orientation) ->
    link = ($scope, elem, attrs) ->
      $timeout ->
        swiperId = attrs.sliderName
        navigation = elem.next()
        wrapper = elem.children(".swiper-wrapper")
        pager = navigation.children(".swiper-pagination")

        initFn = ->
          if !wrapper.length then return

          if !$scope.$parent.height
            $scope.$parent.height = window.innerHeight - wrapper.offset().top - parseInt($('.content').css('paddingBottom')) - navigation[0].offsetHeight - parseInt(navigation.css('marginTop'))

          wrapper.css 'height', $scope.$parent.height + 'px'

          if $rootScope[swiperId]
            wrapper.children().addClass("slider-loaded")

        options =
          onInit: initFn
          onFirstInit: initFn
          pagination: pager[0]
          paginationClickable: true
          initialSlide: 0

        navigation.children('.arrow.left').click ->
          $scope[swiperId].swipePrev()

        navigation.children('.arrow.right').click ->
          $scope[swiperId].swipeNext()

        $(window).resize ->
          $scope.$parent.height = null

          if $rootScope[swiperId]
            $rootScope[swiperId].reInit()
          else
            $rootScope[swiperId] = elem.swiper(options)

        $rootScope[swiperId] = elem.swiper(options)
        $rootScope[swiperId].swipeTo 0
        return
      , 100
    return link: link
]

directives.directive "rightMenu",[
  "$window"
  ($window)->
    ($scope, elem, attrs) ->
      elem = $(elem[0])

      if (bowser.msie && bowser.version < 11)
        $('.shell-wrapper').addClass('menu-inactive')

        elem.click () ->
          $('.shell-wrapper').toggleClass('menu-active').toggleClass('menu-inactive');
      else
        elem.click () ->
          $('.shell-wrapper').toggleClass('menu-active')
        if (bowser.android && bowser.version <= 4.4)
          $('.shell-1').width($('body').width())
]

directives.directive "scrollNote", ->
  ($scope, elem, attrs) ->
    $scope.$watch 'note', (newVal)->
      if newVal
        $('html, body').animate
          scrollTop: 0

    return

directives.directive "bottomPageStyle",[
  '$orientation'
  ($orientation)->
    ($scope, elem, attrs) ->
      fn = ->
        $('.shell-1 > .content').css('margin-bottom', elem[0].offsetHeight)

        $('.shell-1 > b.second-bg').css('bottom', elem[0].offsetHeight)

      if $orientation.getStateTarget() == 'app' then fn() else setTimeout -> fn()
]

directives.directive "windowResize", [
  "$rootScope"
  '$orientation'
  '$state'
  ($rootScope, $orientation, $state) ->
    ($scope, elem, attrs) ->
      $(window).on 'resize', ->
        $scope.$apply ->
          $orientation.windowResize()
]

directives.directive "scrollTop", [
  "$rootScope"
  '$orientation'
  ($rootScope, $orientation, $state) ->
    ($scope, elem, attrs) ->
      if $orientation.getStateTarget() == 'app' then return

      $('html, body').animate
        scrollTop: 0
]

directives.directive 'animateSorted', ['$timeout'
  ($timeout)->
    restrict: 'A'
    scope: true
    link: ($scope, elem, attrs) ->
      ctrl = $scope[attrs.animateSortedCtrl]

      _this = {}

      fn = ->

        _this.elemPosition = elem.css 'position'

        $(window).resize ->
          setTimeout ->
            _this.childs = elem.find('li')

            elem.css 'height', 0

            _this.childs.each (index, item)->
              item = $ item
              
              order = item.attr('data-animate-sorted-item-order')

              elem.css 'height', elem[0].offsetHeight + item[0].offsetHeight

              topNew = 0
              topOld = 0

              _this.childs.each (index2, item2)->
                item2 = $ item2

                if index2 < index then topOld += item2[0].offsetHeight
                if item2.attr('data-animate-sorted-item-order') < order then topNew += item2[0].offsetHeight


              if $scope[attrs.animateSortedActive]
                elem.addClass 'animateSortedProcess'

                if !_this.childsTransition then _this.childsTransition = $(_this.childs[0]).css 'transition'

                item.css 'left', 0
                item.css 'right', 0
                item.css 'transition', 'all 0s ease 0s'
                item.css 'top', topOld
                item.css 'position', 'absolute'
                item.css 'transition', _this.childsTransition

                $timeout ->
                  item.css 'top', topNew

                setTimeout ->
                  item.removeClass 'animateSortedProcess'
                , parseInt(elem.css 'transition-duration') * 1000

        $scope.$watch 'strikeScreenShow', (newVal)->
          if newVal
            return

          _this.childs = elem.find('li')

          elem.css 'height', 0

          _this.childs.each (index, item)->
            item = $ item

            elem.css 'height', elem[0].offsetHeight + item[0].offsetHeight

        $scope.$watch attrs.animateSortedActive, (newVal)->
          _this.childs = elem.find('li')
          _this.elemHeight = elem.css 'height'

          if !_this.childsPosition then _this.childsPosition = $(_this.childs[_this.childs.length - 1]).css 'position'

          if newVal
            elem.css 'position', 'relative'
            elem.css 'height', elem[0].offsetHeight

            _this.animateSortedActive = true
          else
            elem.css 'position', _this.elemPosition
            elem.css 'height', _this.elemHeight

            _this.animateSortedActive = false

          _this.childs.each (index, item)->
            item = $ item

            order = item.attr('data-animate-sorted-item-order')

            if newVal
              topNew = 0
              topOld = 0

              item.addClass 'animateSortedProcess'

              _this.childs.each (index2, item2)->
                item2 = $ item2

                if index2 < index then topOld += item2[0].offsetHeight
                if item2.attr('data-animate-sorted-item-order') < order then topNew += item2[0].offsetHeight

              if !_this.childsTransition then _this.childsTransition = $(_this.childs[0]).css 'transition'

              item.css 'left', 0
              item.css 'right', 0
              item.css 'transition', 'all 0s ease 0s'
              item.css 'top', topOld
              item.css 'position', 'absolute'
              item.css 'transition', _this.childsTransition
              $timeout ->
                item.css 'top', topNew

              setTimeout ->
                item.removeClass 'animateSortedProcess'

                if index == _this.childs.length - 1 && ctrl && ctrl.sortedEnd then ctrl.sortedEnd()
              , parseInt(item.css 'transition-duration') * 1000
            else if ( _this.animateSortedActive)
              item.css 'position', _this.childsPosition
              item.css 'top', 'auto'

      $timeout fn
]

app.directive "chooseAvatarSwiper", [
  "$rootScope"
  "$timeout",
  ($rootScope, $timeout) ->
    scope:
      ctrl: '=chooseAvatarSwiperCtrl'
    link: ($scope, elem, attrs) ->
      if !$scope.$parent.$last
        return

      initFn = ->
        if !$('.swiper-wrapper').length then return

        addPrevNextElemClass()

      addPrevNextElemClass = ->
        currentActiveItem = container.find('.swiper-slide-active')

        if !lastActiveItem || lastActiveItem != currentActiveItem
          container.find('.prev-active').removeClass 'prev-active'
          container.find('.next-active').removeClass 'next-active'

          currentActiveItem.prev().addClass('prev-active')
          currentActiveItem.next().addClass('next-active')

          lastActiveItem = currentActiveItem

      getAvatar = ->
        index = container.find('.swiper-slide-active').index()
        obj = $scope.$parent.avatars[index]

        obj: obj
        index: index

      randomIntFromInterval = (min, max) ->
        Math.floor Math.random() * (max - min + 1) + min

      options =
        onInit: initFn
        onFirstInit: initFn
        slidesPerView: 4
        watchActiveIndex: true
        centeredSlides: true
        resizeReInit: true
        grabCursor: true
        onTouchMove: addPrevNextElemClass
        onTouchEnd: ->
          addPrevNextElemClass()

          avatar = getAvatar()

          $scope.ctrl.chooseAvatar avatar.obj, avatar.index
        onSlideClick: (swiper, event)->
          target = $(event.target).closest '.swiper-slide'

          slideIndex = target.prevAll().length

          $scope.ctrl.slideTo slideIndex
        onSwiperCreated: (swiper)->

          $scope.ctrl.slideTo = (index = 'random')->
            if typeof index != 'number' then index = randomIntFromInterval(0, elem.siblings().length)

            swiper.swipeTo(index)

            addPrevNextElemClass()

            avatar = getAvatar()

            $scope.ctrl.chooseAvatar avatar.obj, avatar.index

          $scope.ctrl.createdSuccess()

      if $('html').hasClass 'ie9'
        options.simulateTouch = false;

      container = elem.closest('.swiper-container')

      swiper = container.swiper(options)
]

directives.directive "iePlaceholders",[
  "$rootScope"
  "$timeout"
  "$window"
  ($rootScope, $timeout, $window)->
    ($scope, elem, attrs) ->
      if bowser.msie and bowser.version == "9.0"
        if $('form[name="registrationForm"]').length > 0
          $timeout ->
            $('.input').each (index, value) ->
              txt = $(this).attr("placeholder")
              $(this).css('color', 'gray')
              $(this).val -> 
                if $(this).val() == "" then txt else ""

              $(this).bind 'focus', (event) ->
                $(this).css('color', 'black')
                $(this).next().hide()
                $(this).val ->
                  if $(this).val() == txt then "" else this.val();

              $(this).bind 'blur', (event) ->
                if $(this).val().length == 0
                  $(this).css('color', 'gray')
                  $(this).next().show()
                  $(this).val($(this).attr("placeholder"))
          , 100

      else if bowser.msie and bowser.version == "10.0"
        if $('form[name="registrationForm"]').length > 0
          $timeout ->
            $('.input').each (index, value) ->

              $(this).bind 'focus', (event) ->
                $(this).next().hide()

              $(this).bind 'blur', (event) ->
                if $(this).val().length == 0
                  $(this).next().show()
          , 100
]

directives.directive "ieContentHeight",[
  "$rootScope"
  "$interval"
  "$window"
  ($rootScope, $interval, $window)->
    ($scope, elem, attrs) ->
      if (bowser.msie)
        equalizerHeight = () ->
          left = $('.shell-1').first()
          right = $('.shell-1').last()
          $('div[ui-view="right"]').height("100%")
          $('div[ui-view="left"]').height("100%")
          if left.outerHeight() > right.outerHeight()
            $('div[ui-view="right"]').height(left.outerHeight())
            $('b.line').height(left.outerHeight())
          else
            $('div[ui-view="left"]').height(right.outerHeight())
            $('b.line').height(right.outerHeight())

        setHeight = () ->
          equalizerHeight()
          timer = $interval ->
            equalizerHeight()
          , 500, count = 2
          $scope.$on '$destroy', ->
            if angular.isDefined(timer) 
              $interval.cancel timer
              timer = undefined

        setHeight()

        if $('.tabs').find('a[data-ng-click]').length > 0
          $('.tabs').find('a[data-ng-click]').click () ->
            setHeight()

        $(window).resize ->
          setHeight()
]

directives.directive "checkStockAndroid", ->
  ($scope, elem, attrs) ->
    isAndroid = navigator.userAgent.indexOf("Android") >= 0
    webkitVer = parseInt((/WebKit\/([0-9]+)/.exec(navigator.appVersion) or 0)[1], 10) or undefined
    isNativeAndroid = isAndroid and webkitVer <= 534 and navigator.vendor.indexOf("Google") is 0

    if isNativeAndroid
      $('html').addClass 'android'

directives.directive "devicesHover", ->
  ($scope, elem, attrs) ->
    elem.on "touchstart", "a[data-ng-click]", ->
      $(@).addClass "hover"

    elem.on "touchend", "a[data-ng-click]", ->
      $(@).removeClass "hover"


directives.directive "logoutBeforeLeave",[
  "$rootScope"
  "ipCookie"
  ($rootScope, $ipCookie)->
    ($scope, elem, attrs) ->
      $(window).unload ()->
        if !$rootScope.logoutAfterLogout then return

        $ipCookie.remove('sessionid');
        $ipCookie.remove('token');
]

directives.directive "devicesHover", ->
  ($scope, elem, attrs) ->
    elem.on "touchstart", "a[data-ng-click]", ->
      $(@).addClass "hover"

    elem.on "touchend", "a[data-ng-click]", ->
      $(@).removeClass "hover"