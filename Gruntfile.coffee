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

    coffeelint:
      app:
        files:
          src: ['src/**/*.coffee', 'test/**/*.coffee', 'Gruntfile.coffee']
        options:
          configFile: 'coffeelint.json'


  # Plugins
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'

  # Tasks
  @registerTask 'compile', ['coffee:compile']

  @registerTask 'default', ['compile']
  @registerTask 'test', ['coffeelint:app']
