# Moudle dependencies
pbkdf2 = require 'pbkdf2-sha256'
crypto = require 'crypto'
cipherSpec = require './cipher-aes-256-gcm'

# Iterations for PBKDF2
KEY_ITERATIONS = 10000

# Encoding for access tokens
ENCODING = 'base64'

# Creates and parses access tokens
class AccessTokenManager

  # Creates an AccessTokenManager
  # @param {string | Buffer} key Base key from which to derive encryption key
  # @param {string | Buffer} salt Random data used to form derived key
  constructor: (key, salt) ->
    key = pbkdf2(key, salt, KEY_ITERATIONS, cipherSpec.KEY_SIZE)
    @cipher = new cipherSpec.Cipher key, crypto.pseudoRandomBytes

  # Creates an access token
  # @param {Object} data Data that will be embedded in the access token
  # @param {Number} expiration Lifetime in minutes of the access token
  # @param {Function} callback Callback function to handle access token or error
  createAccessToken: (data, expiration, callback) ->
    now = Math.floor(Date.now() / 1000) # Current timestamp without milliseconds
    expiration = now + expiration * 60
    tokenData = {data: data, expiration: expiration}
    @cipher.encryptData tokenData, ENCODING, callback

  # Verifies an access token and retrieves it's data, throws an {@code Error} if
  # the token is invalid or has already expired
  # @param {String} token Encrypted access token
  # @return {Object} The data that was embedded in the access token
  getAccessTokenData: (accessToken) ->
    accessToken = @cipher.decryptData accessToken, ENCODING
    if not accessToken
      throw new Error 'Invalid access token'
    if accessToken.expiration * 1000 < Date.now()
      throw new Error 'Expired access token'
    accessToken.data

# Exports
module.exports = AccessTokenManager
