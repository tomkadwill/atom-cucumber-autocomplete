fs = require 'fs'
path = require 'path'

propertyPrefixPattern = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When)\s(?:[a-zA-Z]+\.?){0,2})$/

module.exports =
  selector: '.source.feature, .feature'
  filterSuggestions: true

  getSuggestions: ({bufferPosition, editor}) ->
    # return unless @isEditingAnAtomPackageFile(editor)
    file = editor.getText()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    @getCompletions(line, file)

  load: ->
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

    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      return if error?
      @completions = {}
      classes = JSON.parse(content)
      return

  getCompletions: (line, file) ->
    completions = []
    match =  propertyPrefixPattern.exec(line)?[1]
    return completions unless match

    results = []
    regex = /(Given|And|When|Then)(.*)/g
    while (myRegexArray = regex.exec(file)) != null
      results.push({"text":myRegexArray[2].replace /^\s+|\s+$/g, ""})

    for feature in fs.readdirSync("/Users/thomaskadwill/Workspace/babylon/rails/features")
      continue unless /.feature/.test(feature)
      data = fs.readFileSync "/Users/thomaskadwill/Workspace/babylon/rails/features/#{feature}", 'utf8'
      while (myRegexArray2 = regex.exec(data)) != null
        results.push({"text":myRegexArray2[2].replace /^\s+|\s+$/g, ""})

    return results

clone = (obj) ->
  newObj = {}
  newObj[k] = v for k, v of obj
  newObj

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
