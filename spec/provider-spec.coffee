model = require '../lib/provider'

describe "provider model", ->
  describe "featuresDirectory", ->
    it "gets feature directory from configuration", ->
      atom.config.set("cucumber-autocomplete.path", "/some_path")
      expect(model.featuresDirectory("cucumber-autocomplete.path")).toEqual "/some_path"

  describe "rootDirectory", ->
    it "gets the root directory", ->
      expect(model.rootDirectory()).toEqual atom.project.rootDirectories[0].path
