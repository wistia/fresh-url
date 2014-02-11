module.exports = (grunt) ->

  # Build tasks.
  grunt.registerTask 'build', ['coffee', 'uglify']
  grunt.registerTask 'default', 'build'

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
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-release'
