# Module dependencies
crypto = require 'crypto'

# URL to access Facebook's Graph API
GRAPH_URL = 'https://graph.facebook.com/v2.0'

# Hashing algorithm used to generate HMAC for the application secret proof
APP_SECRET_PROOF_HMAC_ALGORITHM = 'sha256'

# Encoding for the application secret proof
APP_SECRET_PROOF_ENCODING = 'hex'

# Constructs a URL to request and id using Facebook's Graph API
# @param {string} accessToken Facebook access token
# @param {string} appSecretProof Proof of application secret (optional)
# @returns {string} URL that can be used to request the user's id
constructIdUrl = (accessToken, appSecretProof) ->
  path = GRAPH_URL + '/me?fields=id&access_token=' + accessToken
  if appSecretProof
    path += '&appsecret_proof=' + appSecretProof
  path

# Creates an application secret proof for an access token
# @param {string} accessToken Facebook access token
# @param {string} appSecret Application secret
# @returns {string} Application secret proof that can be included in requests
createAppSecretProof = (accessToken, appSecret) ->
  hmac = crypto.createHmac APP_SECRET_PROOF_HMAC_ALGORITHM, appSecret
  hmac.end accessToken
  hmac.read().toString APP_SECRET_PROOF_ENCODING

# Handles authenticated request to Facebook
class FacebookAuthProvider

  # Creates a FacebookAuthProvider
  # @param {Object} requestHandler Handler for HTTP requests
  # @param {string} appSecret Application secret (optional, if not null the
  #                 requests will be sent with a proof of application secret
  constructor: (@requestHandler, @appSecret) ->

  # Gets the user id associated with an access token
  # @param {string} accessToken Facebook access token
  # @param {Function} callback Funciton to handle the id or an error
  getUserId: (accessToken, callback) ->
    if not accessToken
      return callback new Error 'Invalid access token'
    if @appSecret?
      appSecretProof = createAppSecretProof(accessToken, @appSecret)
    url = constructIdUrl accessToken, appSecretProof
    @requestHandler.get url, (error, response, body) ->
      if error
        # Request error
        return callback error
      try
        body = JSON.parse body
      catch
        # Parsing error
        return callback new Error 'Unable to retrieve data'
      if response.statusCode != 200
        # Response error
        if body.error
          return callback new Error body.error.message
        return callback new Error 'Unknown error, code: ' + response.statusCode
      callback null, body.id

# Exports
module.exports = FacebookAuthProvider
