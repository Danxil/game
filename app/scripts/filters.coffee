"use strict"

filters = angular.module("filters", [])

filters.filter "maxSymbols", ->
  (input, maxLength) ->
    input = input.slice(0, maxLength) + "..."  if input.length > maxLength
    input

filters.filter "reverse", ->
  (input) ->
    input.slice().reverse()

filters.filter "pagination", ->
  (input, start, max) ->
    input.slice start, max

filters.filter "fixedNumber", ->
  (number) ->
    arr = []
    i = 0

    while i < number
      arr.push i

      i++

    arr