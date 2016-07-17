'use babel';
var model = require('../lib/provider');

describe("provider model", function() {
  describe("featuresDirectory", function() {
    it("gets feature directory from configuration", function() {
      atom.config.set("cucumber-autocomplete.path", "/some_path");
      expect(model.featuresDirectory("cucumber-autocomplete.path")).toEqual("/some_path");
    });
  });

  describe("rootDirectory", function() {
    it("gets the root directory", function() {
      expect(model.rootDirectory()).toEqual(atom.project.rootDirectories[0].path);
    });
  });

  describe("matchCucumberKeyword", function() {
    it("matches Given keyword", function() {
      let line = "Given something";
      expect(model.matchCucumberKeyword(line)).toEqual(true);
    });

    it("matches the 'And' keyword", function() {
      let line = "And something";
      expect(model.matchCucumberKeyword(line)).toEqual(true);
    });

    it("matches the 'When' keyword", function() {
      let line = "When something";
      expect(model.matchCucumberKeyword(line)).toEqual(true);
    });

    it("matches the 'Then' keyword", function() {
      let line = "Then something";
      expect(model.matchCucumberKeyword(line)).toEqual(true);
    });

    it("doesn't match if there are no keywords", function() {
      let line = "I something";
      expect(model.matchCucumberKeyword(line)).toEqual(false);
    });
  });

  describe("featuresDirError", function() {
    it("raises error with dir path", function() {
      expect(function(){ model.featureDirError('blah/', 'home'); }).toThrow(new Error("Cannot find features directory at blah/home"));
    })
  });

  describe("replacedCucumberRegex", function() {
    it("doesn't replace anything if there aren't any cucumber variables", function() {
      let step = "I should see the index page";
      expect(model.replacedCucumberRegex(step)).toEqual("I should see the index page");
    });

    it("replaces cucumber number variables with autocomplete variables", function() {
      let step = "there are (\\d+) users";
      expect(model.replacedCucumberRegex(step)).toEqual("there are ${1:numberArgument} users");
    });

    it("replaces cucumber text variables with autocomplete variables", function() {
      let step = "I select \"(.*?)\" in the admin panel"
      expect(model.replacedCucumberRegex(step)).toEqual("I select \"${1:textArgument}\" in the admin panel");
    });

    it("replaces multiple cucumber text variables with autocomplete variables", function() {
      let step = `(.*?)" can add text "(.*?)" for "(.*?)" hours and "(.*?)" minutes`
      expect(model.replacedCucumberRegex(step)).toEqual("${1:textArgument}\" can add text \"${1:textArgument}\" for \"${1:textArgument}\" hours and \"${1:textArgument}\" minutes");
    });
  });

  describe('file reading', () => {
    it('should read files directly from the directory provided', () => {
      const rootPath = process.cwd();
      const featureFilePaths = model.searchForPattern(`${rootPath}/spec/features`, /test\.feature/);
      expect(featureFilePaths.length).toEqual(1);
      const matchesExpected = featureFilePaths[0].match(/test\.feature/);
      expect(Boolean(matchesExpected)).toEqual(true);
    });

    it('should read files from subdirectories', () => {
      const rootPath = process.cwd();
      const featureFilePaths = model.searchForPattern(`${rootPath}/spec/features`, /childTest\.feature/);
      expect(featureFilePaths.length).toEqual(1);
      const matchesExpected = featureFilePaths[0].match(/childTest\.feature/);
      expect(Boolean(matchesExpected)).toEqual(true);
    });

    it('should return an empty array if no matches are found', () => {
      const rootPath = process.cwd();
      const featureFilePaths = model.searchForPattern(`${rootPath}/spec/features`, /fakeTest\.feature/);
      expect(featureFilePaths.length).toEqual(0);
    });

    describe('step files', () => {
      it('should pull in lines from step definitions', () => {
        model.rootDirectory = () => process.cwd();
        atom.config.set("cucumber-autocomplete.path", `/spec/features`);
        const stepDefs = model.scanStepDefinitionsDir();
        stepDefs.forEach( stepDef => expect(stepDef.snippet).toEqual('a sample step file'));
      });
    });
  });
});
