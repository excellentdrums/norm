module.exports = class Fields
  @field: (name, options = {}) ->
    @defaults or= {}
    @defaults[name] = options.default || null
