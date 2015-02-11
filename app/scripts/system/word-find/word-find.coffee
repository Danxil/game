(->
  'use strict'
  angular.module('danxil.word-find', []).constant '$config',
    indexAttr: 'data-wf-index'
    valueAttr: 'data-wf-value'
    disableAttr: 'wfDisable'
    matrixClass: 'wf-matrix'
    rowClass: 'wf-row'
    itemClass: 'wf-item'
    handlerClass: 'wf-handler'
    touchBlockClass: 'wf-touch-block'
    selectedVClass: 'wf-vertical'
    selectedHClass: 'wf-horisontal'
    selectedDClass: 'wf-diagonal'
    selectedFirstClass: 'wf-first'
    selectedLastClass: 'wf-last'
    selectedLeftClass: 'wf-left'
    selectedRightClass: 'wf-right'
    selectedClass: 'wf-selected'
    noClearClass: 'wf-no-clear'
    matrixId: Math.round(Math.random() * 1000000)

  mainModule = angular.module('danxil.word-find')

  mainModule.factory '$wfHelper', [
    '$document'
    '$window'
    '$config'
    ($document, $window, $config) ->
      _self = this

      setIndex: (elem, index) ->
        elem.attr $config.indexAttr, index

      getItemIndex: (elem) ->
        parseInt(elem.attr $config.indexAttr)

      getItemRowIndex: (elem) ->
        parseInt(@getItemRow(elem).attr($config.indexAttr))

      getHandlerItemIndex: (elem) ->
        parseInt(@getHandlerItem(elem).attr $config.indexAttr)

      getHandlerRowIndex: (elem) ->
        parseInt(@getItemRow(@getHandlerItem(elem)).attr($config.indexAttr))

      addSelectedClass:
        vertical: (elem) ->
          elem.addClass $config.selectedClass + ' ' + $config.selectedVClass
        horisontal: (elem) ->
          elem.addClass $config.selectedClass + ' ' + $config.selectedHClass
        diagonal: (elem) ->
          elem.addClass $config.selectedClass + ' ' + $config.selectedDClass
        first: (elem) ->
          elem.addClass $config.selectedFirstClass
        last: (elem) ->
          elem.addClass $config.selectedLastClass
        left: (elem) ->
          elem.addClass $config.selectedLeftClass
        right: (elem) ->
          elem.addClass $config.selectedRightClass

      removeSelectedClass:
        vertical: (elem) ->
          elem.removeClass $config.selectedClass + ' ' + $config.selectedVClass
        horisontal: (elem) ->
          elem.removeClass $config.selectedClass + ' ' + $config.selectedHClass
        diagonal: (elem) ->
          elem.removeClass $config.selectedClass + ' ' + $config.selectedDClass
        first: (elem) ->
          elem.removeClass $config.selectedFirstClass
        last: (elem) ->
          elem.removeClass $config.selectedLastClass
        left: (elem) ->
          elem.removeClass $config.selectedLeftClass
        right: (elem) ->
          elem.removeClass $config.selectedRightClass

      getMatrix: ->
        $('#' + $config.matrixId)

      getTouchBlock: ->
        $('.' + $config.touchBlockClass)

      getItemRow: (elem)->
        elem.closest('.' + $config.rowClass)

      getAllRows: ()->
        @getMatrix().find('.' + $config.rowClass)

      getAllItems: ()->
        @getMatrix().find('.' + $config.itemClass)

      getRowItems: (elem)->
        elem.find('.' + $config.itemClass)

      getItemHandler: (elem)->
        elem.find('.' + $config.handlerClass)

      getHandlerItem: (elem)->
        elem.closest('.' + $config.itemClass)

      getRowByIndex: (index)->
        @getMatrix().find('.' + $config.rowClass + '[' + $config.indexAttr + '=' + index + ']')

      getRowItemByIndex: (row, index)->
        row.find('.' + $config.itemClass + '[' + $config.indexAttr + '=' + index + ']')

      getItemByIndexes: (rowIndex, itemIndex)->
        @getRowItemByIndex(@getRowByIndex(rowIndex), itemIndex)

      getHandlerByIndexes: (rowIndex, itemIndex)->
        @getItemHandler @getItemByIndexes(rowIndex, itemIndex)


      getSelectedHandlers: ()->
        @getMatrix().find('.' + $config.selectedClass)

      getSelectedHandlersResult: ()->
        array = []

        _this = @

        @getSelectedHandlers().each (index, value)->
          handler = $ value

          array.push
            value: handler.attr($config.valueAttr)
            itemIndex: _this.getHandlerItemIndex(handler)
            rowIndex: _this.getHandlerRowIndex(handler)

        array

      getSelectionOrientation: (startItem, currentItem) ->
        startItemIndex = @getItemIndex startItem
        startRowIndex = @getItemRowIndex startItem

        currentItemIndex = @getItemIndex currentItem
        currentRowIndex = @getItemRowIndex currentItem

        if startItemIndex != currentItemIndex && startRowIndex == currentRowIndex then return 'horisontal'
        if startItemIndex == currentItemIndex && startRowIndex != currentRowIndex then return 'vertical'
        if Math.abs(startItemIndex - currentItemIndex) == Math.abs(startRowIndex - currentRowIndex) && startRowIndex != currentRowIndex then return 'diagonal'
        if startItemIndex == currentItemIndex && startRowIndex == currentRowIndex then return 'point'

      cancelSelectHandler: (elem)->
        @removeSelectedClass.vertical elem
        @removeSelectedClass.horisontal elem
        @removeSelectedClass.diagonal elem
        @removeSelectedClass.first elem
        @removeSelectedClass.last elem
        @removeSelectedClass.left elem
        @removeSelectedClass.right elem

      cancelSelectAllHandlers: ()->
        _this = @

        @getAllItems().each (index, elem)->
          handler = _this.getItemHandler $(elem)

          _this.cancelSelectHandler(handler)

      selectLine: (startItem, currentItem)->
        startItemIndex = @getItemIndex startItem
        startRowIndex = @getItemRowIndex startItem

        currentItemIndex = @getItemIndex currentItem
        currentRowIndex = @getItemRowIndex currentItem

        orientation = @getSelectionOrientation startItem, currentItem

        _this = this

        switch orientation
          when 'horisontal'
            _this.getAllRows().each (rowIndex, row)->
              row = $ row

              _this.getRowItems(row).each (itemIndex, item)->
                item = $ item

                handler = _this.getItemHandler(item)

                if ((itemIndex >= startItemIndex && itemIndex <= currentItemIndex) || (itemIndex <= startItemIndex && itemIndex >= currentItemIndex)) && rowIndex == startRowIndex

                  _this.removeSelectedClass.vertical handler
                  _this.removeSelectedClass.diagonal handler

                  _this.addSelectedClass[orientation] handler

                  if (startItemIndex > currentItemIndex && itemIndex == currentItemIndex) || (currentItemIndex > startItemIndex && itemIndex == startItemIndex)
                    _this.addSelectedClass.first handler

                  if startItemIndex > currentItemIndex && itemIndex!= currentItemIndex
                    _this.removeSelectedClass.first handler

                  if (startItemIndex > currentItemIndex && itemIndex == startItemIndex) || (currentItemIndex > startItemIndex && itemIndex == currentItemIndex)
                    _this.addSelectedClass.last handler

                  if startItemIndex < currentItemIndex && itemIndex!= currentItemIndex
                    _this.removeSelectedClass.last handler
                else
                  _this.cancelSelectHandler(handler)

          when 'vertical'
            _this.getAllRows().each (rowIndex, row)->
              row = $ row

              _this.getRowItems(row).each (itemIndex, item)->
                item = $ item

                handler = _this.getItemHandler(item)

                if ((rowIndex >= startRowIndex && rowIndex <= currentRowIndex) || (rowIndex <= startRowIndex && rowIndex >= currentRowIndex)) && itemIndex == startItemIndex

                  _this.removeSelectedClass.horisontal handler
                  _this.removeSelectedClass.diagonal handler

                  _this.addSelectedClass[orientation] handler

                  if (startRowIndex > currentRowIndex && rowIndex == currentRowIndex) || (currentRowIndex > startRowIndex && rowIndex == startRowIndex)
                    _this.addSelectedClass.first handler

                  if startRowIndex > currentRowIndex && rowIndex != currentRowIndex
                    _this.removeSelectedClass.first  handler

                  if (startRowIndex > currentRowIndex && rowIndex == startRowIndex) || (currentRowIndex > startRowIndex && rowIndex == currentRowIndex)
                    _this.addSelectedClass.last handler

                  if startRowIndex < currentRowIndex && rowIndex != currentRowIndex
                    _this.removeSelectedClass.last  handler
                else
                  _this.cancelSelectHandler(handler)
          when 'diagonal'
            _this.getAllRows().each (rowIndex, row)->
              row = $ row

              _this.getRowItems(row).each (itemIndex, item)->
                item = $ item

                handler = _this.getItemHandler(item)

                if ((rowIndex >= startRowIndex && rowIndex <= currentRowIndex) || (rowIndex <= startRowIndex && rowIndex >= currentRowIndex)) && ((startItemIndex > currentItemIndex && itemIndex <= startItemIndex) || (startItemIndex < currentItemIndex && itemIndex >= startItemIndex)) && Math.abs(startRowIndex - rowIndex) == Math.abs(startItemIndex - itemIndex)

                  _this.removeSelectedClass.horisontal handler
                  _this.removeSelectedClass.vertical handler

                  _this.addSelectedClass[orientation] handler

                  diff = if startItemIndex - currentItemIndex > 0 then -1 else 1

                  if (startRowIndex > currentRowIndex && rowIndex == currentRowIndex) || (currentRowIndex > startRowIndex && rowIndex == startRowIndex)
                    _this.addSelectedClass.first handler

                  if (startRowIndex < currentRowIndex && startItemIndex < currentItemIndex) || (startRowIndex > currentRowIndex && startItemIndex > currentItemIndex)
                    _this.addSelectedClass.left handler
                    _this.removeSelectedClass.right handler
                  else
                    _this.addSelectedClass.right handler
                    _this.removeSelectedClass.left handler

                  if startRowIndex > currentRowIndex && itemIndex!= currentItemIndex
                    _this.removeSelectedClass.first  handler

                  if (startRowIndex > currentRowIndex && rowIndex == startRowIndex) || (currentRowIndex > startRowIndex && rowIndex == currentRowIndex)
                    _this.addSelectedClass.last handler

                  if startRowIndex < currentRowIndex && itemIndex!= currentItemIndex
                    _this.removeSelectedClass.last  handler
                else
                  _this.cancelSelectHandler(handler)

          when 'point'
            handler = @getHandlerByIndexes(startRowIndex, startItemIndex)

            @cancelSelectAllHandlers()

            @addSelectedClass.horisontal handler
            @addSelectedClass.first handler
            @addSelectedClass.last handler

      getTouchCoords: (event)->
        if window.navigator.msPointerEnabled? || window.PointerEvent?
          x: event.pageX - @getTouchBlock().offset().left
          y: event.pageY - @getTouchBlock().offset().top
        else
          x: event.originalEvent.changedTouches[0].pageX - @getTouchBlock().offset().left
          y: event.originalEvent.changedTouches[0].pageY - @getTouchBlock().offset().top

      calculateOffsetMatrix: ()->
        _this = this

        matrix = []

        @getAllRows().each (rowIndex, row)->
          row = $ row

          _this.getRowItems(row).each (itemIndex, item)->
            item = $ item

            itemPosition = item.position()

            if !matrix[rowIndex]
              matrix[rowIndex] = []

            matrix[rowIndex][itemIndex] =
              top: itemPosition.top
              bottom: itemPosition.top + item.height()
              left: itemPosition.left
              right: itemPosition.left + item.width()

        matrix
  ]

  mainModule.controller 'wordFindCtrl', [
    '$scope'
    ($scope) ->
      @$scope = $scope

      return
  ]

  mainModule.directive 'wordFind', [
    '$config'
    '$wfHelper'
    ($config, $wfHelper)->
      restrict: 'A'
      controller: 'wordFindCtrl'
      scope: true
      link: ($scope, elem, attrs, ctrl) ->
        getTouchItem = (coords)->
          for row, rowIndex in ctrl.offsetMatrix
            for item, itemIndex in row
              if coords.x >= item.left && coords.x <= item.right && coords.y >= item.top && coords.y <= item.bottom
                return $wfHelper.getItemByIndexes(rowIndex, itemIndex)

        bindTouchBlock = (touchBlock)->
          touchBlock.bind touchEvents.tStart, touchStart

        unbindTouchBlock = (touchBlock)->
          touchBlock.unbind touchEvents.tStart

        touchStart = (event)->
          touchBlock.unbind touchEvents.tStart

          if window.navigator.msPointerEnabled? || window.PointerEvent?
            $(document).bind touchEvents.tEnd, touchEnd
          touchBlock.bind touchEvents.tEnd, touchEnd
          touchBlock.bind touchEvents.tMove, touchMove

          item = getTouchItem $wfHelper.getTouchCoords(event)
          handler = $wfHelper.getItemHandler item

          ctrl.startItem = item
          ctrl.currentItem = ctrl.startItem

          $wfHelper.selectLine ctrl.startItem, ctrl.currentItem

        touchMove = (event)->

          event.preventDefault();
          
          item = getTouchItem $wfHelper.getTouchCoords(event)

          if !item
            return

          handler = $wfHelper.getItemHandler item

          ctrl.currentItem = item

          $wfHelper.selectLine ctrl.startItem, ctrl.currentItem

        touchEnd = (event)->
          if window.navigator.msPointerEnabled? || window.PointerEvent?
            $(document).unbind touchEvents.tEnd
          touchBlock.unbind touchEvents.tEnd
          touchBlock.unbind touchEvents.tMove

          $scope.$apply ->
            $scope.wfCtrl.finishSelection $wfHelper.getSelectedHandlersResult()

          $wfHelper.cancelSelectHandler $wfHelper.getSelectedHandlers()

        elem.addClass($config.matrixClass).attr 'id', $config.matrixId

        $(window).resize -> ctrl.offsetMatrix = $wfHelper.calculateOffsetMatrix()

        $(document).on 'dragstart', ->
          return false

        $scope.$watch attrs[$config.disableAttr], (newValue)->
          if newValue
            unbindTouchBlock touchBlock

            ctrl.$scope.wfState = 'disable'
          else
            bindTouchBlock touchBlock

            ctrl.$scope.wfState = 'enable'

        touchBlock = $ '<div class="' + $config.touchBlockClass + '">'

        elem.append touchBlock

        _this = {}
  ]

  mainModule.directive 'wordFindRow', [
    '$wfHelper'
    '$config'
    ($wfHelper, $config) ->
      restrict: 'A'
      require: '^wordFind'
      scope: true
      link: ($scope, elem, attrs, ctrl) ->
        $wfHelper.setIndex elem, $scope.$index

        elem.addClass $config.rowClass

        if $scope.$last then $scope.$lastRow = true
  ]

  mainModule.directive 'wordFindItem', [
    '$wfHelper'
    '$config'
    ($wfHelper, $config) ->
      restrict: 'A'
      require: '^wordFind'
      scope: true
      link: ($scope, elem, attrs, ctrl) ->
        $wfHelper.setIndex elem, $scope.$index

        elem.addClass $config.itemClass

        $rowScope = $scope.$parent.$parent

        if $rowScope.$last && $scope.$last
          ctrl.offsetMatrix = $wfHelper.calculateOffsetMatrix()

          ctrl.$scope.wfState = 'enable'
  ]

  mainModule.directive 'wordFindHandler', [
    '$wfHelper'
    '$config'
    ($wfHelper, $config) ->
      restrict: 'A'
      require: '^wordFind'
      scope: true
      link: ($scope, elem, attrs, ctrl) ->
        startSelection = ->
          $scope.$apply ->
            ctrl.startItem = _this.item
            ctrl.currentItem = ctrl.startItem

            $(window).bind 'mouseup', finishSelection

            $wfHelper.selectLine ctrl.startItem, ctrl.currentItem

            ctrl.$scope.wfState = 'process'

        processSelection = ->
          ctrl.currentItem = _this.item

          $wfHelper.selectLine ctrl.startItem, ctrl.currentItem

        finishSelection = ->
          $(window).unbind 'mouseup'

          $scope.$apply ->
            $scope.wfCtrl.finishSelection $wfHelper.getSelectedHandlersResult()

          $wfHelper.cancelSelectHandler $wfHelper.getSelectedHandlers()

        _this = {}

        elem.addClass $config.handlerClass

        $scope.$watch 'wfState', (newValue)->
          switch newValue
            when 'enable'
              _this.item = $wfHelper.getHandlerItem(elem)

              _this.item.unbind 'mouseenter'

              _this.item.bind 'mousedown', startSelection
            when 'process'
              _this.item.unbind 'mousedown'

              _this.item.bind 'mouseenter', processSelection
            when 'disable'
              _this.item.unbind 'mousedown'
              _this.item.unbind 'mouseenter'
  ]
)()