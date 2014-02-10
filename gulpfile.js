var gulp = require('gulp'),
    gutil = require('gulp-util'),
    coffee = require('gulp-coffee'),
    concat = require('gulp-concat'),
    uglify = require('gulp-uglify');

gulp.task('default', function(){
    // place code for your default task here
});

gulp.task('coffee', function() {
    gulp.src('./lib/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./dist/'))
    .pipe(concat('fresh_url.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest('./dist/'))
})
