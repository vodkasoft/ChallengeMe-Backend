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
TEST = 'test'

# Build soruces
coffeeSources = [
  "#{SRC}/*.coffee"
  "#{SRC}/access-token/**/*.coffee"
  "#{SRC}/facebook-auth/**/*.coffee"
]

# Test sources
testSources = "#{TEST}/**/*.coffee"

# Lint
gulp.task 'lint', ->
  gulp.src coffeeSources
  .pipe plumber()
  .pipe coffeelint()

# Test
gulp.task 'test', ->
  require 'coffee-script/register'
  gulp.src testSources
  .pipe mocha()

# Build
gulp.task 'build', ['lint', 'test'], ->
  gulp.src coffeeSources, base: SRC
  .pipe plumber()
  .pipe coffee bare: true
  .pipe gulp.dest "#{DIST}/"

# Clean
gulp.task 'clean', ->
  gulp.src 'dist/', read: false
  .pipe clean()

# Watch
gulp.task 'watch', ['lint', 'test', 'build'], ->
  gulp.watch [coffeeSources], ['lint', 'test', 'build']

# Defualt
gulp.task 'default', ['lint', 'test', 'build']
