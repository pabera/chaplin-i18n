define [
  'underscore'
], (_) ->
  'use strict'

  i18n =
    localization : {}
    __locale : null
    defaultLocale : 'en'

    init: () ->
      @__locale = window.__locale || null
      @__locale = @defaultLocale unless @__locale?

      # load language dynamically if other then en
      if @__locale != @defaultLocale
        require ["text!locale/#{@__locale}.json"], (localization) =>
          @localization = JSON.parse(localization)


    setDefault: (locale) ->
      @defaultLocale = @__locale = locale

    # Look trough the localization and get the right translation if there is any
    translate: (id, vars = {}) ->
      template = @localization[@__locale]?[id] or @localization[@__locale[0..1]]?[id]
      unless template?
        # You don't need to provide a localization for the default language
        template = if @__locale != 'en' then "(?) #{id}" else "#{id}"
        # uncomment the following line to show all missing translations in the console
        # console.log("missing [#{@__locale}] #{id}") if console?.log?
      
      _.template(template, vars)

    t: (i18n_key) ->
      # Find the translation
      result = i18n.translate i18n_key

      # clear arguments to array and remove first and last item
      args = []
      for arg in arguments
        if _i > 0 and _i < arguments.length-1
          args.push arg

      # Replace placeholders in the localization string with given variables
      result.format args

  # Seal the i18n object
  Object.seal? i18n

  i18n