var gulp          = require('gulp');
var jshint        = require('gulp-jshint');
var uglify        = require('gulp-uglify');
var usemin        = require('gulp-usemin');
var concat        = require('gulp-concat');
var run_sequence  = require('run-sequence');
var del           = require('del');
var src           = '/';

// tasks

gulp.task('lint', function() {
    gulp.src(['./scripts/**/*.js', '!./bower_components/**'])
        .pipe(jshint())
        .pipe(jshint.reporter('default'))
        .pipe(jshint.reporter('fail'));
});

gulp.task('clean', function(cb) {
    del(['dist'], cb);
});

gulp.task('usemin', function() {
    return gulp.src('index.html')
        .pipe(usemin({
            js: [uglify()]
        }))
        .pipe(gulp.dest('dist/'));
});

gulp.task('copy-html-files', function() {
    gulp.src(['./views/**/*.html'])
        .pipe(gulp.dest('dist/views'));
});

gulp.task('copy-font-files', function() {
    gulp.src(['./bower_components/bootstrap-css-only/fonts/*'])
        .pipe(gulp.dest('dist/fonts'));

});

// build task for deployment in production

gulp.task('build', function(cb){
        run_sequence('clean', 'lint', 'usemin', 'copy-html-files','copy-font-files', cb);
    }
);

// default task

gulp.task('default', function() {
        run_sequence('lint');
    }
);