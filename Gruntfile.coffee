module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          timeout: 20000
          require: 'coffee-script/register'
          grep: process.env.TESTS

    # Coding standards
    coffeelint:
      all:
        files:
          src: ['components/*.coffee', 'spec/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'ignore'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'test', ['coffeelint', 'mochaTest']
  @registerTask 'default', ['test']
