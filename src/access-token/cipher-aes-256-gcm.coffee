# Moudle dependencies
crypto = require 'crypto'
cipher = require 'node-aes-256-gcm'

# Size for an initialization vector
IV_SIZE = 12

# Size for an authentication tag
TAG_SIZE = 16

# Size for the encryption and decryption key
KEY_SIZE = 32

# Default encoding to use when none is specified
DEFAULT_ENCODING = 'base64'

# Joins segments of encrypted data into a single buffer
# @param {Buffer} iv Initialization vector used to encrypt the data
# @param {Buffer} cipherText Resulting ciphertext form the encryption
# @param {Buffer} tag Message authentication code for the cipherText
# @returns {Buffer} IV, ciphertext and tag concatenated
joinEncryptedData = (iv, ciphertext, tag) ->
  length = IV_SIZE + ciphertext.length + TAG_SIZE
  Buffer.concat [iv, ciphertext, tag], length

# Splits a buffer into the iv, the ciphertext and the tag
# @param {Buffer} Buffer thant contians the iv, ciphertext and tag
# @returns {Object} Object with the iv, the ciphertext and the tag
splitEncryptedData = (encryptedData) ->
  iv: encryptedData.slice 0, IV_SIZE
  ciphertext: encryptedData.slice IV_SIZE, -TAG_SIZE
  tag: encryptedData.slice -TAG_SIZE, encryptedData.length

# Encrypts and decrypts data using AES-256-GCM
class CipherAes256Gcm

  # Creates a CipherAes256Gcm
  # @param {Buffer} key Encryption and decryption key
  # @param {Function} prng Function that creates pseudo-random buffers, must
  #                        receive a number and a callback, can use
  #                        crypto.randomBytes and crypto.pseudoRandomBytes
  constructor: (key, @prng) ->
    if not Buffer.isBuffer key
      throw new TypeError 'Key must be a buffer'
    if key.length != KEY_SIZE
      throw new Error 'Key size must be of #{KEY_SIZE} bytes'
    @key = key

  # Encrypts data using a key
  # @param {Object} data Object to be encrypted
  # @param {Function} callback Funciton to handle encrypted data or error
  encryptData: (data, encoding, callback) ->
    key = @key
    @prng IV_SIZE, (error, iv) ->
      if error
        return callback error
      encoding = encoding || DEFAULT_ENCODING
      data = new Buffer JSON.stringify data
      {ciphertext, auth_tag} = cipher.encrypt key, iv, data, new Buffer []
      encryptedData = joinEncryptedData iv, ciphertext, auth_tag
      callback null, encryptedData.toString encoding

  # Decrypts data using a key
  # @param {Buffer} data Buffer to be decrypted
  # @returns {Object} Data that was encrypted
  decryptData: (encryptedData, encoding) ->
    encoding = encoding || DEFAULT_ENCODING
    encryptedData = new Buffer encryptedData, encoding
    if encryptedData.length < IV_SIZE + TAG_SIZE + 1
      return null
    {iv, ciphertext, tag} = splitEncryptedData encryptedData
    decryption = cipher.decrypt @key, iv, ciphertext, new Buffer([]), tag
    if not decryption.auth_ok
      return null
    JSON.parse decryption.plaintext

# Exports
module.exports.Cipher = CipherAes256Gcm
module.exports.KEY_SIZE = KEY_SIZE
