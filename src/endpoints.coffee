# Default time before a token expires
EXPIRATION = 60 # 1 hour

# Default maximum number of items to retrieve from a query
LIMIT = 20

# Reads the data for the Authorization header from a request
# @param {Request} req Request from which the Authorization header will be read
# @param {string} type Desired authorization type (default any)
# @returns {string} the value for the Authorization header
getAuthorizationHeader = (request, type) ->
  header = request.get 'Authorization'
  if not header or header.length is 0
    return null
  if not type
    return header
  header = header.split ' '
  if header[0] isnt type
    return null
  return header[1]

# Sends a JSON formatted error to the client
# @param {Response} response Response to which the error should be written
# @param {Number} statusCode HTTP status code that should be sent
# @param {String} message Error message
sendError = (response, statusCode, message) ->
  payload =
    error:
      status: statusCode
      message: message
  response.send statusCode, payload

# Configures a router to respond to the data endpoints
# @param {object} router The router that will be configured
# @param {object} options Object with the dependencies for the endpoints
configureRouter = (router, options) ->

  # Extract dependencies from options
  {dataAccess, tokenManager, authProvider} = options

  # Verifies client credentials
  # @param {Request} request Incoming request
  # @param {Response} response Writable stream for response
  # @param {Function} next The next handler to be called
  requireCredentials = (request, response, next) ->
    credentials = getAuthorizationHeader request, 'Basic'
    if not credentials
      return sendError response, 401, 'Credentials required'
    credentials = credentials.split ':'
    if credentials.length isnt 2
      return sendError response, 401, 'Invalid credentials'
    dataAccess.getClient credentials[0], (error, client) ->
      if error or not client.has 'Id'
        return sendError response, 401, 'Invalid credentials'
      clientSecret = client.get 'Secret'
      if clientSecret is credentials[1]
        return next()
      return sendError response, 401, 'Invalid credentials'

  # Verifies access tokens
  # @param {Request} request Incoming request
  # @param {Response} response Writable stream for response
  # @param {Function} next The next handler to be called
  requireToken = (request, response, next) ->
    accessToken = credentials = getAuthorizationHeader request, 'Bearer'
    if not accessToken
      return sendError response, 401, 'Access token required'
    try
      request.tokenData = tokenManager.getAccessTokenData accessToken
    catch error
      return sendError response, 401, error.message
    next()

  # Creates an access token for a user
  # @param {string} id Unique id for the user
  # @param {Funciton} callback Function to handle token or error
  createUserAccessToken = (id, callback) ->
    dataAccess.getOrCreateUser id, (error, user) ->
      if error
        return callback new Error 'Unable to generate access token'
      tokenData = {userId: id}
      tokenManager.createAccessToken tokenData, EXPIRATION, (error, token) ->
        if error
          return callback new Error 'Unable to generate access token'
        callback null, token

  # URL: /login/access_token
  # Method: POST
  # Authentication: Client credentials
  # Authorization: Any client
  #
  # Creates an access token for a user
  #
  # Request parameters:
  #   token: user token from the provider used by the application
  #
  # Returns:
  #  An access token to make requests on behalf of the user
  router.post '/login/access_token', requireCredentials, (request, response) ->
    providerToken = request.body.token
    if not providerToken
      return sendError response, 400, 'No token provided'
    authProvider.getUserId providerToken, (error, id) ->
      if error
        return sendError response, 400, error.message
      createUserAccessToken id, (error, token) ->
        if error
          sendError response, 500, error.message
        responseData =
          token: token
          exp: EXPIRATION
        response.send 201, responseData

  # URL: /users/{id}/profile
  # Method: GET
  # Authentication: User access token
  # Authorization: Any user
  #
  # Obtains the profile information for a user
  #
  # URL parameters:
  #   id: Unique id for the user (accepts 'me' for the current user)
  #
  # Returns:
  #    The profile information for the user
  router.get '/users/:id/profile', requireToken, (request, response) ->
    requestedUserId = if request.params.id is 'me'
      request.tokenData.userId
    else
      request.params.id
    dataAccess.getUser requestedUserId, (error, user) ->
      if error
        return sendError response, 500, 'Unable to retrieve user profile'
      if not user
        return sendError response, 400, 'User does not exist'
      responseData =
        user:
          id: user.get 'Id'
          wins: user.get 'Wins'
          losses: user.get 'Losses'
      response.send 200, responseData

  # URL: /users/{id}/challenges/received
  # Method: GET
  # Authentication: User access token
  # Authorization: Owner (recipient)
  #
  # Obtains the challenges that the user has received
  #
  # URL parameters:
  #   id: Unique id for the user (accepts 'me' for the current user)
  #
  # Query parameters:
  #    limit: Maximum number of challenges to retreive
  #
  # Returns:
  #    The challenges that the user has received
  router.get '/users/:id/challenges/received', requireToken, (request, response) ->
    userId = request.tokenData.userId
    if (request.params.id isnt 'me') and request.params.id isnt userId
      return sendError response, 403, 'Cannot access chanlleges for user'
    limit = request.query.limit || LIMIT
    dataAccess.getReceivedChallenges userId, limit, (error, challenges) ->
      if error
        return sendError response, 500, 'Unable to retrieve challenges'
      responseChallenges = for challenge in challenges
        id: challenge.get 'Id'
        sender: challenge.get 'Sender'
        state: challenge.get 'State'
        type: challenge.get 'Type'
      responseData =
        challenges: responseChallenges
        count: responseChallenges.length
      response.send 200, responseData

  # URL: /users/{id}/challenges/sent
  # Method: GET
  # Authentication: User access token
  # Authorization: Owner (sender)
  #
  # Obtains the challenges that the user has sent
  #
  # URL parameters:
  #   id: Unique id for the user (accepts 'me' for the current user)
  #
  # Query parameters:
  #    limit: Maximum number of challenges to retreive
  #
  # Returns:
  #    The challenges that the user has sent
  router.get '/users/:id/challenges/sent', requireToken, (request, response) ->
    userId = request.tokenData.userId
    if (request.params.id isnt 'me') and request.params.id isnt userId
      return sendError response, 403, 'Cannot access chanlleges for user'
    limit = request.query.limit || LIMIT
    dataAccess.getSentChallenges userId, limit, (error, challenges) ->
      if error
        return sendError response, 500, 'Unable to retrieve challenges'
      responseChallenges = for challenge in challenges
        id: challenge.get 'Id'
        recipient: challenge.get 'Recipient'
        state: challenge.get 'State'
        type: challenge.get 'Type'
      responseData =
        challenges: responseChallenges
        count: responseChallenges.length
      response.send 200, responseData

  # URL: /challenges/{id}
  # Method: GET
  # Authentication: User access token
  # Authorization: Owner (sender or recipient)
  #
  # Obtains the data for a challenge
  #
  # URL parameters:
  #   id: Unique id for the challenge
  #
  # Returns:
  #    The data for the challenge
  router.get '/challenges/:id', requireToken, (request, response) ->
    userId = request.tokenData.userId
    dataAccess.getChallenge request.params.id, (error, challenge) ->
      if error
        return sendError response, 500, 'Unable to retrieve challenge'
      if not challenge
        return sendError response, 400, 'Challenge does not exist'
      senderId = challenge.get 'Sender'
      recipientId = challenge.get 'Recipient'
      if userId not in [senderId, recipientId]
        return sendError response, 403, 'Cannot access challenge'
      responseData =
        challenge:
          id: challenge.get 'Id'
          recipient: challenge.get 'Recipient'
          sender: challenge.get 'Sender'
          data: challenge.get 'Data'
          solution: challenge.get 'Solution'
          state: challenge.get 'State'
          type: challenge.get 'Type'
      response.send 200, responseData

  # URL: /challenges/{id}/state
  # Method: PUT
  # Authentication: User access token
  # Authorization: Owner (recipient)
  #
  # Updates the state of a challenge
  #
  # URL parameters:
  #   id: Unique id for the challenge
  router.put '/challenges/:id/state', requireToken, (request, response) ->
    userId = request.tokenData.userId
    newState = request.body.state
    if not newState
      return sendError response, 400, 'No state provided'
    dataAccess.getChallenge request.params.id, (error, challenge) ->
      if error
        return sendError response, 500, 'Unable to retrieve challenge'
      if not challenge
        return sendError response, 400, 'Challenge does not exist'
      recipientId = challenge.get 'Recipient'
      if recipientId isnt userId
        return sendError response, 403, 'Cannot access challenge'
      challenge.update {State: newState}, (error) ->
        if error
          return sendError response, 500, 'Unable to update state'
        updateStatsCallback = (error) ->
          if error
            return sendError response, 500, 'Error updating user stats'
          response.status 204
          response.end()
        if newState is 'Won'
          return dataAccess.incrementUserWins recipientId, updateStatsCallback
        if newState is 'Lost'
          return dataAccess.incrementUserLosses recipientId, updateStatsCallback
        response.status 204
        response.end()

  # URL: /challenges
  # Method: POST
  # Authentication: User access token
  # Authorization: Any user
  #
  # Creates a challenge
  #
  # Request parameters:
  #   challenge: data for the challenge
  #
  # Returns:
  #  The id's for the challenges sent
  router.post '/challenges', requireToken, (request, response) ->
    userId = request.tokenData.userId
    challengeData = request.body.challenge
    if not challengeData
      return sendError response, 400, 'No challenge data provided'
    requiredAttributes = ['recipients', 'data', 'solution', 'type']
    for attribute in requiredAttributes
      if not challengeData[attribute]
        return sendError response, 400, "Missing attribute #{attribute}"
    dataAccess.createChallenge userId, challengeData, (error, ids) ->
      if error
        return sendError response, 500, 'Unable to create challenge'
      response.send 201, {challenges: ids}

# Exports
module.exports.configureRouter = configureRouter
