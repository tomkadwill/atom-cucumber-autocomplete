fs = require 'fs'
path = require 'path'

PROPERTY_PREFIX_PATTERN = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When)\s(?:[a-zA-Z]+\.?){0,2})$/
PATH_CONFIG_KEY = 'cucumber-autocomplete.path'
CUCUMBER_KEYWORDS_PATTERN = /(Given|And|When|Then)(.*)/g
CUCUMBER_STEP_DEF_PATTERN = /(Given|And|When|Then)\(\/\^(.*?)\$/g

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

    stats = fs.lstatSync("#{@rootDirectory()}#{@featuresDirectory()}/step_definitions");
    if stats.isDirectory()
      #TODO: first search step definitions for your file
      for step_def_file in fs.readdirSync("#{@rootDirectory()}#{@featuresDirectory()}/step_definitions")
        data = fs.readFileSync "#{@rootDirectory()}#{@featuresDirectory()}/step_definitions/#{step_def_file}", 'utf8'
        while (myRegexArray = CUCUMBER_STEP_DEF_PATTERN.exec(data)) != null
          results.push({"snippet":@replacedCucumberRegex(myRegexArray[2])})
    else
      @featureDirError() unless fs.lstatSync("#{@rootDirectory()}#{@featuresDirectory()}").isDirectory()

      for feature in fs.readdirSync("#{@rootDirectory()}#{@featuresDirectory()}")
        continue unless /.feature/.test(feature)
        data = fs.readFileSync "#{@rootDirectory()}#{@featuresDirectory()}/#{feature}", 'utf8'
        while (myRegexArray = CUCUMBER_KEYWORDS_PATTERN.exec(data)) != null
          results.push({"text":myRegexArray[2].replace /^\s+|\s+$/g, ""})

    return results

  matchCucumberKeyword: (line) ->
    PROPERTY_PREFIX_PATTERN.exec(line)?[1] != null

  rootDirectory: ->
    atom.project.rootDirectories[0].path

  featuresDirectory: (path=PATH_CONFIG_KEY) ->
    atom.config.get(path)

  replacedCucumberRegex: (step) ->
    #TODO: figure out how to loop through if there are multiple matches
    #      eg: 1:numberArgument, 2:numberArgument
    step = step.replace(/^\s+|\s+$/g, "")
    step = step.replace(/\(\\d\+\)/g, "${1:numberArgument}")
    step.replace(/\(\.\*\?\)/g, "${1:textArgument}")

  featureDirError: ->
    throw new Error("Cannot find features directory at #{@rootDirectory()}#{@featuresDirectory()}")
