module.exports = class Attributes
  isNew: ->
    not @.get('id')?

  hasChanged: (attr) ->
    if attr then return @.previousAttributes[attr] isnt @.attributes[attr]
    @._changed

  changedAttributes: ->
    now = @.attributes
    old = @.previousAttributes
    changed = false
    for key, val of now
      if old[key] isnt now[key]
        changed = changed || {}
        changed[key] = now[key]
    changed

  get: (attr) ->
    @.attributes[attr]

  set: (attrs) ->
    if not attrs then return @

    now = @.attributes
    if not @.isNew() and not @._changed
      @.previousAttributes = _.clone(now)
    else
      @.previousAttributes or= {}

    for key, val of attrs
      if now[key] isnt val
        now[key] = val
        @._changed = true
