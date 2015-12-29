fs = require 'fs'
path = require 'path'

propertyPrefixPattern = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When)\s(?:[a-zA-Z]+\.?){0,2})$/

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
    completions = []
    match =  propertyPrefixPattern.exec(line)?[1]
    return completions unless match

    results = []
    regex = /(Given|And|When|Then)(.*)/g
    while (myRegexArray = regex.exec(file)) != null
      results.push({"text":myRegexArray[2].replace /^\s+|\s+$/g, ""})

    for feature in fs.readdirSync("#{@rootDirectory()}/features")
      continue unless /.feature/.test(feature)
      data = fs.readFileSync "#{@rootDirectory()}/features/#{feature}", 'utf8'
      while (myRegexArray2 = regex.exec(data)) != null
        results.push({"text":myRegexArray2[2].replace /^\s+|\s+$/g, ""})

    return results

  rootDirectory: ->
    atom.project.rootDirectories[0].path
