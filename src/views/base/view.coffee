# This view class is comming from the Chaplin Boilerplate to make it work with Handlebars
# You need to register a Handlebars Helper in the 'getTemplateFunction' method

define [
  'handlebars'
  'chaplin'
  'lib/i18n'
  'lib/view_helper' # Just load the view helpers, no return value
], (Handlebars, Chaplin, i18n) ->
  'use strict'

  class View extends Chaplin.View

    getTemplateFunction: ->

      # Template compilation
      # --------------------

      # This demo uses Handlebars templates to render views.
      # The template is loaded with Require.JS and stored as string on
      # the view prototype. On rendering, it is compiled on the
      # client-side. The compiled template function replaces the string
      # on the view prototype.
      #
      # In the end you might want to precompile the templates to JavaScript
      # functions on the server-side and just load the JavaScript code.
      # Several precompilers create a global JST hash which stores the
      # template functions. You can get the function by the template name:
      #
      # templateFunc = JST[@templateName]

      # Register Handlebars Helper to use i18n in Templates
      Handlebars.registerHelper 't', (i18n_key) ->
        result = i18n.t i18n_key
        # some further escaping
        result = Handlebars.Utils.escapeExpression result
        new Handlebars.SafeString result
        
      template = @template

      if typeof template is 'string'
        # Compile the template string to a function and save it
        # on the prototype. This is a workaround since an instance
        # shouldn’t change its prototype normally.
        templateFunc = Handlebars.compile template
        @constructor::template = templateFunc
      else
        templateFunc = template

      templateFunc