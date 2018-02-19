/*
* Using GULP to translate a markdown files to html
* Taken from https://code.visualstudio.com/docs/languages/markdown#_step-2-create-a-simple-gulp-task
* the project https://github.com/mcecot/gulp-markdown-it is a 
* wrapper around https://markdown-it.github.io/markdown-it/#MarkdownIt.new
* Node that a very insteresting opportunty is to highlight code
*/
var gulp = require('gulp');
var markdown = require('gulp-markdown-it');

gulp.task('markdown', function() {
    return gulp.src('**/*.md')
        .pipe(markdown())
        .pipe(gulp.dest(function(f) {
            return f.base;
        }));
});

gulp.task('default', ['markdown'], function() {
    gulp.watch('**/*.md', ['markdown']);
});