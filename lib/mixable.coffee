module.exports = class Mixable
  @extend: (mixin) ->
    for name, method of mixin
      @[name] = method

  @include: (mixin) ->
    @extend @constructor.prototype, mixin