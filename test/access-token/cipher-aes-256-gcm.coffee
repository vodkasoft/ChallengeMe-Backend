# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
CipherAes256Gcm = require '../../src/access-token/cipher-aes-256-gcm'

# Mock pseudo-random number generator
mockPrng = (size, callback) ->
  callback null, new Buffer (0 for [0...size])

# Mock pseudo-random number generator, always sends an error
errorPrng = (size, callback) ->
  callback new Error 'Intentional mock error'

# Setup
key = 'key'
salt = 'salt'
cipher = new CipherAes256Gcm key, salt,  mockPrng

# Example data
data =
  text: 'example'

# Encryption for example data
enc = 'AAAAAAAAAAAAAAAAhxphcwBZRHWRpj2QiZCQRQ57kpfhXn/VV6/u0470OpE+Nw=='
encHex = '000000000000000000000000871a61730059447591a63d90899090450e7b9297e15e7fd557afeed38ef43a913e37'

# Module description
describe 'Cipher AES-256-GCM', ->

  it 'should catch PRNG errors', ->
    errorCipher = new CipherAes256Gcm key, salt, errorPrng
    errorCipher.encryptData new Buffer([]), null, (error, encryptedData) ->
      should.exist error
      error.should.be.an.instanceof Error
      should.not.exist encryptedData

  it 'should encrypt with default encoding', ->
    cipher.encryptData data, null, (error, encryptedData) ->
      should.not.exist error
      should.exist encryptedData
      encryptedData.should.equal enc

  it 'should encrypt with specified encoding', ->
    cipher.encryptData data, 'hex', (error, encryptedData) ->
      should.not.exist error
      should.exist encryptedData
      encryptedData.should.be.a 'string'
      encryptedData.should.equal encHex

  it 'should decrypt with default encoding', ->
    data = cipher.decryptData enc, null
    should.exist data
    data.should.deep.equal data

  it 'should decrypt with specified encoding', ->
    data = cipher.decryptData encHex, 'hex'
    should.exist data
    data.should.deep.equal data

  it 'should catch invalid data size', ->
    data = cipher.decryptData '', 'base64'
    should.not.exist data

  it 'should catch wrong encoding for decryption', ->
    data = cipher.decryptData encHex, 'base64'
    should.not.exist data
