AtomRefactoringToolsView = require './atom-refactoring-tools-view'
{CompositeDisposable} = require 'atom'
indentString = require 'indent-string'
stripIndent = require 'strip-indent'

module.exports = AtomRefactoringTools =
  atomRefactoringToolsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomRefactoringToolsView = new AtomRefactoringToolsView(state.atomRefactoringToolsViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomRefactoringToolsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-refactoring-tools:extract-method': => @extractMethod(),
      'core:cancel': => @modalPanel.hide()
      'core:confirm': =>
        @extractMethodFinish() # TODO: this contaminates the search panel.

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomRefactoringToolsView.destroy()

  serialize: ->
    atomRefactoringToolsViewState: @atomRefactoringToolsView.serialize()

  extractMethod: ->
    console.log 'atom-refactoring-tools:extract-method'

    if atom.workspace.getActiveTextEditor()
      # TODO: This implementation needs to be completely rewritten.
      @modalPanel.hide()
      element = @atomRefactoringToolsView.reset().getElement()
      @modalPanel = atom.workspace.addModalPanel(item: element, visible: false)
      @modalPanel.show()
      element.querySelector('atom-text-editor').focus()

  extractMethodFinish: ->
    @modalPanel.hide()
    if editor = atom.workspace.getActiveTextEditor()
      methodName = @atomRefactoringToolsView.getText()
      editor.cutSelectedText()
      methodBody = atom.clipboard.read()
      strippedMethodBody = stripIndent methodBody
      indentedMethodBody = indentString strippedMethodBody, '  '
      extractedMethod = """
        def #{methodName}
        #{indentedMethodBody}
        end
      """
      atom.clipboard.write extractedMethod
