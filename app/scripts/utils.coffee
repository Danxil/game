# naive functional tools implementation
__ =
  curry2 : (f) -> (x) -> (y) -> f x, y
  curry3 : (f) -> (x) -> (y) -> (z) -> f x, y, z  # do not know any function with more than 3 args
  flip : (f) -> (x, y) -> f y, x                  # flip
  flipC : (f) -> @curry2 @flip f                  # flip and then curry
  doLater : (f) -> setTimeout f, 250              # short timeout to switch context


_.mixin __
