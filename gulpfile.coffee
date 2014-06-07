# Dependencies
gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
clean = require 'gulp-clean'
plumber = require 'gulp-plumber'
mocha = require 'gulp-mocha'

# Directories
DIST = 'dist'
SRC = 'src'

# Soruces
coffeeSources = ['src/*.coffee']

# Lint
gulp.task 'lint', ->
  gulp.src coffeeSources
  .pipe plumber()
  .pipe coffeelint()

# Test
gulp.task 'test', ->
  require 'coffee-script/register'
  gulp.src 'test/**/*.coffee'
  .pipe mocha()

# Build
gulp.task 'build', ['lint'], ->
  gulp.src coffeeSources, base: SRC
  .pipe plumber()
  .pipe coffee bare: true
  .pipe gulp.dest "#{DIST}/"

# Clean
gulp.task 'clean', ->
  gulp.src 'dist/', read: false
  .pipe clean()

# Watch
gulp.task 'watch', ['lint', 'build'], ->
  gulp.watch [coffeeSources], ['lint', 'build']

# Defualt
gulp.task 'default', ['lint', 'build']
