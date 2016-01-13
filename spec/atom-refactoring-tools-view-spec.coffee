AtomRefactoringToolsView = require '../lib/atom-refactoring-tools-view'
faker = require 'faker'

describe "AtomRefactoringToolsView", ->
  pristineHTML = """
    <label>Name for the new method:</label>
    <atom-text-editor mini />
  """

  beforeEach ->
    @view = new AtomRefactoringToolsView
    @element = @view.getElement()

  describe 'constructor', ->
    it 'sets the HTML content to the pristine panel', ->
      expect(@element).toHaveHtml pristineHTML

  describe 'reset', ->
    it 'resets the HTML content to the pristine panel', ->
      @element.innerHTML = 'bogus'
      @view.reset()
      expect(@element.textContent).not.toContain 'bogus'
      expect(@element).toHaveHtml pristineHTML

    it 'returns the object, for chainability', ->
      expect(@view.reset()).toBe @view

  describe 'getText', ->
    it 'returns the contents of the mini editor', ->
      editor = @element.querySelector('atom-text-editor[mini]').getModel()
      text = faker.lorem.sentence()
      editor.setText text

      expect(@view.getText()).toBe text
