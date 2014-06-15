# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
cipherAes256Gcm = require '../../src/access-token/cipher-aes-256-gcm'

# Mock pseudo-random number generator
mockPrng = (size, callback) ->
  callback null, new Buffer (0 for [0...size])

# Mock pseudo-random number generator, always sends an error
errorPrng = (size, callback) ->
  callback new Error 'Intentional mock error'

# Setup
key = new Buffer (0 for [0...cipherAes256Gcm.KEY_SIZE])
cipher = new cipherAes256Gcm.Cipher key, mockPrng

# Example data
data =
  text: 'example'

# Encryption for example data
enc = 'AAAAAAAAAAAAAAAAtYU0WDUUSVQlK72y14PxfVAdDenhok+IUh6qXVvsJ2CWDw=='
encHex = '000000000000000000000000b585345835144954252bbdb2d783f17d501d0de9e1a24f88521eaa5d5bec2760960f'

################################################################################
# Cipher AES-256-GCM                                                           #
################################################################################

describe 'Cipher AES-256-GCM', ->

  it 'should check that key is a Buffer', ->
    errorConstructor = ->
      new cipherAes256Gcm.Cipher 'key', mockPrng
    errorConstructor.should.throw TypeError

  it 'should check that the key size is correct', ->
    errorConstructor = ->
      fakeKey = new Buffer (0 for [0...cipherAes256Gcm.KEY_SIZE - 1])
      new cipherAes256Gcm.Cipher fakeKey, mockPrng
    errorConstructor.should.throw Error, /size/

  it 'should catch PRNG errors', (done) ->
    errorCipher = new cipherAes256Gcm.Cipher key, errorPrng
    errorCipher.encryptData new Buffer([]), null, (error, encryptedData) ->
      should.exist error
      error.should.be.an.instanceof Error
      should.not.exist encryptedData
      done()

  it 'should encrypt with default encoding', (done) ->
    cipher.encryptData data, null, (error, encryptedData) ->
      should.not.exist error
      should.exist encryptedData
      encryptedData.should.equal enc
      done()

  it 'should encrypt with specified encoding', (done) ->
    cipher.encryptData data, 'hex', (error, encryptedData) ->
      should.not.exist error
      should.exist encryptedData
      encryptedData.should.be.a 'string'
      encryptedData.should.equal encHex
      done()

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
