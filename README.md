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

## API Reference

### Data Types

#### Client

A client is an application that has been registered with the backend.
To authenticate the client a valid id and secret must be provided.

##### Attributes

| Name        | Type      | Description                                        |
|:------------|-----------|:---------------------------------------------------|
| id          | string    | String that uniquely identifies the application    |
| secret      | string    | Secret used to authenticate the client             |

#### User

A user is a person who uses a client application and has registered an third
party account with the backend *(Currently Facebook using an OAuth2 access
token)*.

##### Attributes

| Name        | Type      | Description                                        |
|:------------|-----------|:---------------------------------------------------|
| id          | string    | Unique identification provided by a third party    |
| wins        | number    | Total number of challenges the user has won        |
| losses      | number    | Total number of challenges the user has lost       |

#### Challenge

Challenges are managed like emails. Each challenge has a recipient and a sender,
but instead of a subject and a body it has data, a solution and a type.

##### Attributes

| Name        | Type      | Description                                        |
|:------------|-----------|:---------------------------------------------------|
| id          | string    | String that uniquely identifies the challenge      |
| sender      | string    | Id of the user who sent the challenge              |
| recipient   | string    | Id of the user who received the challenge (owner)  |
| type        | string    | Category for the challenge                         |
| data        | string    | JSON representation of the challenge's definition  |
| solution    | string    | JSON representation of the challenge's solution    |

### Endpoints

| Resource URI                          | Description                                   |
|:--------------------------------------|:----------------------------------------------|
| POST /login/access_token              | Create an access token for a user             |
| GET /users/*{id}*/profile             | Obtain the profile information for a user     |
| GET /users/*{id}*/challenges/received | Obtain the challenges that the user has sent  |
| GET /users/*{id}*/challenges/sent     | Obtain the profile information for a user     |
| GET /challenges/*{id}*                | Obtain the data for a challenge               |
| PUT /challenges/*{id}*/state          | Update the state of a challenge               |
| POST /challenges                      | Create a challenge                            |


## Authors

[Albin Arias](https://github.com/alariju)<br>
[Jose Mario Marín](https://github.com/josemario94)<br>
[Federico Salas](https://github.com/fjhoelsg)

## License

All code and documentation are released under the [MIT license](http://opensource.org/licenses/MIT).
Code, documentation and assets form other projects, libraries or frameworks may be subject to different licenses.
