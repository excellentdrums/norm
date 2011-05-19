module.exports = class Fields
  @field: (name, options = {}) ->
    field = {}
    field.default = options.default || null
    @.fields or= {}
    @.fields[name] = field

  @defaultAttributes: ->
    defaults = {}
    return defaults unless @.fields?
    for name, options of @.fields
      defaults[name] = options.default
    defaults

  @defaultAttribute: (name) ->
    return undefined unless @.fields?
    @.fields[name].default