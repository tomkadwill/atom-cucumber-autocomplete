fs = require 'fs'
path = require 'path'

propertyPrefixPattern = /(?:^|\[|\(|,|=|:|\s)\s*(And\s(?:[a-zA-Z]+\.?){0,2})$/

module.exports =
  selector: '.source.feature, .feature'
  filterSuggestions: true

  getSuggestions: ({bufferPosition, editor}) ->
    # return unless @isEditingAnAtomPackageFile(editor)
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    @getCompletions(line)

  load: ->
    @loadCompletions()
    atom.project.onDidChangePaths => @scanProjectDirectories()
    @scanProjectDirectories()

  scanProjectDirectories: ->
    @packageDirectories = []
    atom.project.getDirectories().forEach (directory) =>
      return unless directory?
      @readMetadata directory, (error, metadata) =>
        @packageDirectories.push(directory)

  readMetadata: (directory, callback) ->
    fs.readFile path.join(directory.getPath(), 'package.json'), (error, contents) ->
      unless error?
        try
          metadata = JSON.parse(contents)
        catch parseError
          error = parseError
      callback(error, metadata)

  loadCompletions: ->
    @completions ?= {}

    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      return if error?
      @completions = {}
      classes = JSON.parse(content)
      @loadProperty('atom', 'Atom', classes)
      return

  getCompletions: (line) ->
    completions = []
    match =  propertyPrefixPattern.exec(line)?[1]
    return completions unless match
    [
      {"text":"I am signed in as a general admin"},
      {"text":"I should not be able to remove any region"},
      {"text":"I should be able to remove regions"},
      {"text":"I am signed in as a Global Admin"}
    ]

  getPropertyClass: (name) ->
    atom[name]?.constructor?.name

  loadProperty: (propertyName, className, classes, parent) ->
    classCompletions = classes[className]
    return unless classCompletions?

    @completions[propertyName] = completions: []

    for completion in classCompletions
      @completions[propertyName].completions.push(completion)
      if completion.type is 'property'
        propertyClass = @getPropertyClass(completion.name)
        @loadProperty(completion.name, propertyClass, classes)
    return

clone = (obj) ->
  newObj = {}
  newObj[k] = v for k, v of obj
  newObj

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
