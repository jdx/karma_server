module.exports = function(grunt) {
    'use strict';
    require('load-grunt-tasks')(grunt);

    grunt.initConfig({
      watch: {
        files: '**/*.coffee',
        tasks: ['mochaTest']
      },
      mochaTest: {
        test: {
          options: {
            reporter: 'spec'
          },
        src: ['test/**/*.coffee']
        }
      }

    });

    grunt.registerTask('default', ['mochaTest']);
};
