fs = require 'fs'
path = require 'path'

PROPERTY_PREFIX_PATTERN = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When)\s(?:[a-zA-Z]+\.?){0,2})$/
PATH_CONFIG_KEY = 'cucumber-autocomplete.path'

module.exports =
  selector: '.source.feature, .feature'
  filterSuggestions: true

  load: ->
    # Not used

  getSuggestions: ({bufferPosition, editor}) ->
    file = editor.getText()
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    @getCompletions(line, file)

  getCompletions: (line, file) ->
    return [] unless @matchCucumberKeyword(line)

    results = []
    regex = /(Given|And|When|Then)(.*)/g
    while (myRegexArray = regex.exec(file)) != null
      results.push({"text":myRegexArray[2].replace /^\s+|\s+$/g, ""})

    for feature in fs.readdirSync("#{@rootDirectory()}#{@featuresDirectory()}")
      continue unless /.feature/.test(feature)
      data = fs.readFileSync "#{@rootDirectory()}#{@featuresDirectory()}/#{feature}", 'utf8'
      while (myRegexArray2 = regex.exec(data)) != null
        results.push({"text":myRegexArray2[2].replace /^\s+|\s+$/g, ""})

    return results

  matchCucumberKeyword: (line) ->
    PROPERTY_PREFIX_PATTERN.exec(line)?[1] != null

  rootDirectory: ->
    atom.project.rootDirectories[0].path

  featuresDirectory: (path=PATH_CONFIG_KEY) ->
    atom.config.get(path)
