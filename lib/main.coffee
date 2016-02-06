provider = require './provider'

module.exports =
  config:
    path:
      type: 'string'
      title: 'Path'
      default: '/features'
      description: '
        This is the relative path (from your project root) to your projects
        features directory.
      '

  activate: -> provider.load()

  getProvider: -> provider
