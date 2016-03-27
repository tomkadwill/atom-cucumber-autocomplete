model = require '../lib/provider'

describe "provider model", ->
  describe "featuresDirectory", ->
    it "gets feature directory from configuration", ->
      atom.config.set("cucumber-autocomplete.path", "/some_path")
      expect(model.featuresDirectory("cucumber-autocomplete.path")).toEqual "/some_path"

  describe "rootDirectory", ->
    it "gets the root directory", ->
      expect(model.rootDirectory()).toEqual atom.project.rootDirectories[0].path

  describe "matchCucumberKeyword", ->
    it "matches Given keyword", ->
      line = "Given something"
      expect(model.matchCucumberKeyword(line)).toEqual true

    it "matches And keyword", ->
      line = "And something"
      expect(model.matchCucumberKeyword(line)).toEqual true

    it "matches When keyword", ->
      line = "When something"
      expect(model.matchCucumberKeyword(line)).toEqual true

    it "matches Then keyword", ->
      line = "Then something"
      expect(model.matchCucumberKeyword(line)).toEqual true

    it "doesn't match if there are no keywords", ->
      line = "I something"
      expect(model.matchCucumberKeyword(line)).toEqual false
