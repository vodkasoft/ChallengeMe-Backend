# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
FacebookAuthProvider = require '../../src/facebook-auth'

# Sample id
sampleId = 1

# HMAC Test setup
# Test Case 2 from RFC4231
# http://tools.ietf.org/html/rfc4231#section-4.3
hmacTest =
  key: 'Jefe'
  data: 'what do ya want for nothing?'
  digest: '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843'

# Mock request handler, successful request
validRequestHandler =
  get: (url, handler) ->
    handler null, {statusCode: 200}, '{"id": ' + sampleId + '}'

# Mock request handler, expect app_secret_proof
requestHandlerWithAppSecretProof =
  get: (url, handler) ->
    url.should.contain 'appsecret_proof=' + hmacTest.digest
    handler null, {statusCode: 200}, '{"id": ' + sampleId + '}'

# Mock request handler, sends an error
errorRequestHandler =
  get: (url, handler) ->
    handler new Error 'Mock error'

# Mock request handler, sends invalid data
invalidDataRequestHandler =
  get: (url, handler) ->
    handler null, {statusCode: 200}, '{'

# Mock request handler, wrong status code with error
wrongStatusCodeRequestHandlerWithError =
  get: (url, handler) ->
    handler null, {statusCode: 400}, '{"error": {"message": "Mock Error"}}'

# Mock request handler, wrong status code without error
wrongStatusCodeRequestHandlerWithoutError =
  get: (url, handler) ->
    handler null, {statusCode: 400}, '{}'

# Module description
describe 'facebook-auth', ->

  it 'should get the Facebook id form a valid response', ->
    handler = validRequestHandler
    facebookAuthProvider = new FacebookAuthProvider handler
    facebookAuthProvider.getUserId 'accessToken', (error, id) ->
      should.not.exist error
      should.exist id
      id.should.equal sampleId

  it 'should send appsecret_proof if application secret is provided', ->
    handler = requestHandlerWithAppSecretProof
    facebookAuthProvider = new FacebookAuthProvider handler, hmacTest.key
    facebookAuthProvider.getUserId hmacTest.data, (error, id) ->
      should.not.exist error
      should.exist id
      id.should.equal sampleId

  it 'should catch errors in the request', ->
    handler = errorRequestHandler
    facebookAuthProvider = new FacebookAuthProvider handler
    facebookAuthProvider.getUserId 'accessToken', (error, id) ->
      should.exist error
      should.not.exist id

  it 'should send an error when invalid data is received', ->
    handler = invalidDataRequestHandler
    facebookAuthProvider = new FacebookAuthProvider handler
    facebookAuthProvider.getUserId 'accessToken', (error, id) ->
      should.exist error
      should.not.exist id

  it 'should send status code error if exists', ->
    handler = wrongStatusCodeRequestHandlerWithError
    facebookAuthProvider = new FacebookAuthProvider handler
    facebookAuthProvider.getUserId 'accessToken', (error, id) ->
      should.exist error
      error.message.should.equal 'Mock Error'
      should.not.exist id

  it 'should send error if status code error does not have an error', ->
    handler = wrongStatusCodeRequestHandlerWithoutError
    facebookAuthProvider = new FacebookAuthProvider handler
    facebookAuthProvider.getUserId 'accessToken', (error, id) ->
      should.exist error
      should.not.exist id
