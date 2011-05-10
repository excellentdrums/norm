module.exports = class Attributes
  get: (attr) ->
    @.attributes[attr]

  set: (attrs) ->
    if not attrs then return @
    now = @.attributes

    for attr of attrs
      val = attrs[attr]
      if not _.isEqual(now[attr], val)
        now[attr] = val
