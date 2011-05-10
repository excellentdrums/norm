module.exports = class Mixable
  @extend: (mixin) ->
    for name, method of mixin
      @[name] = method

  @include: (mixin) ->
    for name, method of mixin.prototype
      @.prototype[name] = method
    @extend mixin