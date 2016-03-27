'use babel';
var fs = require('fs');
var path = require('path');

const PATH_CONFIG_KEY = 'cucumber-autocomplete.path';
const CUCUMBER_STEP_DEF_PATTERN = /(Given|And|When|Then)\(\/\^(.*?)\$/g;
const CUCUMBER_KEYWORDS_PATTERN = /(Given|And|When|Then)(.*)/g;
const PROPERTY_PREFIX_PATTERN = /(?:^|\[|\(|,|=|:|\s)\s*((?:And|Given|Then|When)\s(?:[a-zA-Z]+\.?){0,2})$/;

module.exports = {
  selector: '.source.feature, .feature',
  filterSuggestions: true,
  load: function() {},
  getSuggestions: function({bufferPosition, editor}) {
    let file = editor.getText();
    let line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition]);
    return this.getCompletions(line, file);
  },
  getCompletions: function(line, file) {
    if (!this.matchCucumberKeyword(line)) return [];
    let results = [];

    try {
      let stats = fs.lstatSync(`${this.rootDirectory()}${this.featuresDirectory()}/step_definitions`)
      if(stats.isDirectory()) {
        return this.scanStepDefinitionsDir(results);
      } else {
        return this.scanFeaturesDir(results)
      }
    } catch (e) {
      return this.scanFeaturesDir(results)
    }
  },
  scanStepDefinitionsDir: function(results) {
    //TODO: first search step definitions for your file
    for (var step_def_file of fs.readdirSync(`${this.rootDirectory()}${this.featuresDirectory()}/step_definitions`)) {
      let data = fs.readFileSync(`${this.rootDirectory()}${this.featuresDirectory()}/step_definitions/${step_def_file}`, 'utf8');
      while((myRegexArray = CUCUMBER_STEP_DEF_PATTERN.exec(data)) != null) {
        results.push({"snippet":this.replacedCucumberRegex(myRegexArray[2])});
      }
    }

    return results
  },
  scanFeaturesDir: function(results) {
    if (!fs.lstatSync(`${this.rootDirectory()}${this.featuresDirectory()}`).isDirectory()) this.featureDirError();

    for (var feature of fs.readdirSync(`${this.rootDirectory()}${this.featuresDirectory()}`)) {
      if (!/.feature/.test(feature)) continue;
      let data = fs.readFileSync(`${this.rootDirectory()}${this.featuresDirectory()}/${feature}`, 'utf8');
      while((myRegexArray = CUCUMBER_KEYWORDS_PATTERN.exec(data)) != null) {
        results.push({"text":myRegexArray[2].replace(/^\s+|\s+$/g, "")});
      }
    }

    return results
  },
  matchCucumberKeyword: function(line) {
    return PROPERTY_PREFIX_PATTERN.exec(line) != null;
  },
  rootDirectory: function() {
    return atom.project.rootDirectories[0].path;
  },
  featuresDirectory: function(path=PATH_CONFIG_KEY) {
    return atom.config.get(path);
  },
  replacedCucumberRegex: function(step) {
    //TODO: figure out how to loop through if there are multiple matches
    //      eg: 1:numberArgument, 2:numberArgument
    step = step.replace(/^\s+|\s+$/g, "");
    step = step.replace(/\(\\d\+\)/g, "${1:numberArgument}");
    return step.replace(/\(\.\*\?\)/g, "${1:textArgument}")
  },
  featureDirError: function() {
    throw new Error(`Cannot find features directory at ${this.rootDirectory()}${this.featuresDirectory()}`);
  }
};
