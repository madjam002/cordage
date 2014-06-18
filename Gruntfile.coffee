module.exports = ->

  @initConfig

    coffee:
      compile:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    watch:
      compile:
        files: ['src/**/*.coffee']
        tasks: ['compile']
      test:
        files: ['src/**/*.coffee']
        tasks: ['test']

    coffeelint:
      app:
        files:
          src: ['src/**/*.coffee', 'test/**/*.coffee', 'Gruntfile.coffee']
        options:
          configFile: 'coffeelint.json'

    jasmine_node:
      options:
        coffee: true
        useHelpers: true
      app: ['test/']


  # Plugins
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-jasmine-node'

  # Tasks
  @registerTask 'compile', ['coffee:compile']

  @registerTask 'default', ['compile']
  @registerTask 'test', ['jasmine_node:app', 'coffeelint:app']
