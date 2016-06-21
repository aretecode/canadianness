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

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'ignore'
      routes:
        files:
          src: ['routes/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'ignore'
      root:
        files:
          src: ['*.coffee']
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
