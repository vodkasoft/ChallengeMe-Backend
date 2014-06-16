# Module dependencies
uuid = require 'node-uuid'

# Interface for datastore interactions
class DataAccess

  # Gets a challenge
  # @param {string} id Unique id for the challenge
  # @param {Function} callback Function to handler challenge or error
  getChallenge: (id, callback) ->
    @Models.Challenge.getItemByKeys {Id: id}, callback

  # Gets a client
  # @param {string} id Unique id for the client
  # @param {Function} callback Function to handler client or error
  getClient: (id, callback) ->
    @Models.Client.getItemByKeys {Id: id}, callback

  # Gets a user or creates it if it does not exist
  # @param {string} id Unique id for the user
  # @param {Function} callback Function to handler user or error
  getOrCreateUser: (id, callback) ->
    @getUser id, (error, user) =>
      if error
        return callback error
      if user
        return callback  null, user
      @createUser id, callback

  # Gets the challenges a user has received
  # @param {string} id Unique id for the user
  # @param {number} limit Maximum number of challenges to return
  # @param {Function} callback Function to handler challenges or error
  getReceivedChallenges: (id, limit, callback) ->
    query = new @Query @Models.Challenge
    query.limit limit
    query.useIndex 'GSI_Recipient'
    query.equalTo 'Recipient', id
    query.find callback

  # Gets the challenges a user has sent
  # @param {string} id Unique id for the user
  # @param {number} limit Maximum number of challenges to return
  # @param {Function} callback Function to handler challenges or error
  getSentChallenges: (id, limit, callback) ->
    query = new @Query @Models.Challenge
    query.limit limit
    query.useIndex 'GSI_Sender'
    query.equalTo 'Sender', id
    query.find callback

  # Gets a user
  # @param {string} id Unique id for the user
  # @param {Function} callback Function to handler user or error
  getUser: (id, callback) ->
    @Models.User.getItemByKeys {Id: id}, (error, user) ->
      if error
        return callback error
      if user.has 'Id'
        return callback null, user
      return callback()

  # Creates a DataAccess
  # @params {Object} Constructors for models to Query
  # @params {Object} Query the constructor for a query operation
  constructor: (@Models, @Query) ->

  # Creates a challenge
  # @param {string} senderId Unique id for the user who sends the challenge
  # @param {Object} challengeData Attributes for the challenge
  # @param {Function} callback Function to handle ids or error
  createChallenge: (senderId, challengeData, callback) ->
    challenge = new @Models.Challenge
    challenge.set 'Sender', senderId
    challenge.set 'Type', challengeData.type
    challenge.set 'Data', challengeData.data
    challenge.set 'Solution', challengeData.solution
    challenge.set 'State', 'Unread'
    savedIds = []
    counter = challengeData.recipients.length
    savedError = null
    for recipient in challengeData.recipients
      id = uuid.v4()
      challenge.set 'Id', id
      challenge.set 'Recipient', recipient
      challenge.save (error) ->
        if error
          savedError = error
        else
          savedIds.push id
        if --counter is 0
          if savedError
            return callback savedError
          callback null, savedIds

  # Creates a user
  # @param {string} id Unique id for the user
  # @param {Function} callback Function to handler user or error
  createUser: (id, callback) ->
    user = new @Models.User {Id: id}
    user.set 'Wins', 0
    user.set 'Loses', 0
    user.save (error) ->
      if error
        return callback error
      return callback null, user

# Exports
module.exports = DataAccess
