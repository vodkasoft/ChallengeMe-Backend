# ChallengeMe Backend
> Backend for the [ChallengeMe](https://github.com/vodkasoft/ChallengeMe) game

Provides endpoints to manage users and challenges.

## Compiling

ChallengeMe Backend uses [Gulp](http://gulpjs.com) to run build tasks. Our
gulpfile is written in [CoffeeScript](http://coffeescript.org) and several
plugins are required to run the tasks.

### Installing Gulp

Gulp requires a global installation to run the tasks, to install Gulp run
`npm install -g gulp`

### Installing CoffeeScript

CoffeeScript requires a global installation to compile CoffeeScript files into
JavaScript, to install CoffeeScript run `npm install -g coffee-script`

### Installing Dependencies

ChallengeMe Backend depends on several packages; additionally it
requires some Gulp packages to run build tasks. To install all the
required packages run `npm install` from the root directory.

### Gulp Tasks

The following tasks can be run from Gulp

- *lint*: Lints the CoffeeScript files
- *test*: Runs the Mocha test suite
- *build*: Lints and compiles the CoffeeScript files
- *clean*: Removes build artifacts
- *watch*: Sets a watch task to lint and compile CoffeeScript files
- *default*: Lints and compiles the CoffeeScript files

## Authors

[Albin Arias](https://github.com/alariju)<br>
[Jose Mario Marín](https://github.com/josemario94)<br>
[Federico Salas](https://github.com/fjhoelsg)

## License

All code and documentation are released under the [MIT license](http://opensource.org/licenses/MIT).
Code, documentation and assets form other projects, libraries or frameworks may be subject to different licenses.
