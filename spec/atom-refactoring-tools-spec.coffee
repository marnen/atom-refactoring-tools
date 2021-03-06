require 'jasmine-set'

AtomRefactoringTools = require '../lib/atom-refactoring-tools'
indentString = require 'indent-string'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomRefactoringTools", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('atom-refactoring-tools')

  describe 'atom-refactoring-tools:extract-method', ->
    describe 'text is selected', ->
      set 'selectedText', -> 'Here is some selected text!'

      beforeEach ->
        workspace = atom.workspace
        waitsForPromise ->
          workspace.open()
        runs ->
          @editor = workspace.getActiveTextEditor()

          # TODO: we need to test with not all the text selected
          @editor.setText selectedText
          @editor.selectAll()
          atom.commands.dispatch workspaceElement, 'atom-refactoring-tools:extract-method'
          waitsForPromise -> activationPromise

      it 'shows a modal panel', ->
        jasmine.attachToDOM(workspaceElement)
        extractModal = workspaceElement.querySelector('.atom-refactoring-tools')
        expect(extractModal).toBeVisible()
        expect(extractModal.textContent).toContain 'Name for the new method:'
        expect(extractModal).toContain 'atom-text-editor[mini]'

      it 'does not change the text yet', ->
        expect(@editor.getText()).toBe selectedText

      describe 'accept modal', ->
        set 'clipboard', atom.clipboard.read

        beforeEach ->
          @methodName = 'foo_bar'
          workspaceElement.querySelector('.atom-refactoring-tools atom-text-editor[mini]').getModel().setText @methodName
          atom.commands.dispatch workspaceElement, 'core:confirm'

        it 'dismisses the modal', ->
          extractModal = workspaceElement.querySelector('.atom-refactoring-tools')
          expect(extractModal).not.toBeVisible()

        it 'cuts the selection to the clipboard, with the method name', ->
          expect(@editor.getText()).toBe ''
          expect(clipboard).toBe """
            def #{@methodName}
              #{selectedText}
            end
          """

        describe 'multiple lines', ->
          multilineText = """
            line one
            line two
              line three
            line four
          """
          set 'selectedText', -> multilineText

          it 'indents all lines equally', ->
            expect(clipboard).toBe """
              def #{@methodName}
              #{indentString selectedText, '  '}
              end
            """

          describe 'nonzero indent', ->
            set 'selectedText', -> indentString multilineText, '      '

            it 'strips the existing indent before indenting', ->
              expect(clipboard).toBe """
                def #{@methodName}
                #{indentString multilineText, '  '}
                end
              """

      describe 'cancel modal', ->
        it 'does not keep the last typed method name', ->
          miniEditor = workspaceElement.querySelector('.atom-refactoring-tools atom-text-editor[mini]').getModel()
          miniEditor.setText 'some dummy text'
          atom.commands.dispatch workspaceElement, 'core:cancel'
          atom.commands.dispatch workspaceElement, 'atom-refactoring-tools:extract-method'
          miniEditor = workspaceElement.querySelector('.atom-refactoring-tools atom-text-editor[mini]').getModel()
          expect(miniEditor.getText()).toBe ''
