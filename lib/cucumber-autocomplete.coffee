CucumberAutocompleteView = require './cucumber-autocomplete-view'
{CompositeDisposable} = require 'atom'

module.exports = CucumberAutocomplete =
  cucumberAutocompleteView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @cucumberAutocompleteView = new CucumberAutocompleteView(state.cucumberAutocompleteViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @cucumberAutocompleteView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'cucumber-autocomplete:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @cucumberAutocompleteView.destroy()

  serialize: ->
    cucumberAutocompleteViewState: @cucumberAutocompleteView.serialize()

  toggle: ->
    console.log 'CucumberAutocomplete was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
