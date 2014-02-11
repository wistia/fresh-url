module.exports = (grunt) ->

  # Build tasks.
  grunt.registerTask 'build', ['coffee', 'uglify']
  grunt.registerTask 'default', 'build'
  grunt.registerTask 'test', ['build', 'karma']

  grunt.initConfig
    coffee:
      options:
        bare: true
      compile:
        expand: true
        flatten: false
        cwd: 'lib'
        src: '**/*.coffee'
        dest: 'dist'
        ext: '.js'

    uglify:
      dist:
        expand: true
        cwd: 'dist'
        src: ['**/*.js', '!**/*.min.js']
        dest: 'dist'
        ext: '.min.js'

    watch:
      coffee:
        files: '<%= coffee.compile.src %>'
        tasks: ['build']

    karma:
      unit:
        configFile: 'karma.conf.coffee'

    release:
      options:
        file: 'bower.json'
        npm: false

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-release'
  grunt.loadNpmTasks 'grunt-karma'
