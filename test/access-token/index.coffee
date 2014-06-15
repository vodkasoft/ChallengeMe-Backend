# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
AccessTokenManager = require '../../src/access-token'

# Set up
testManager = new AccessTokenManager 'key', 'salt'
sampleData =
  x: 1
  y: 'hello'
sampleDataAccessToken = 'dXCPggyHTUo3Xw1vUD+tTgDjhzERwCWZ12BZ/k3/srfaAa8IzAwY4bDLQiXZi2vMXtRGG83SoKppCtOOvmQgcfT2iKKpDhPXjhr38sea2sb6'
invalidToken = 'cXCPggyHTUo3Xw1vUD+tTgDjhzERwCWZ12BZ/k3/srfaAa8IzAwY4bDLQiXZi2vMXtRGG83SoKppCtOOvmQgcfT2iKKpDhPXjhr38sea2sb6'
expiredToken = 'Q28qG+TT/1TK1MwLTe1x7lYoxd/QWpqj84+sB/oSRyTZt6lH9GPcbL1lkkBeNeoieBAwUjh0rtgWykey3xVbiTe3l7lQk2+4+5FZ89MYnC4='

################################################################################
# Token Manager                                                                #
################################################################################

describe 'Token Manager', ->

  it 'should create an access token', (done) ->
    testManager.createAccessToken sampleData, 0, (error, accessToken) ->
      should.not.exist error
      should.exist accessToken
      accessToken.should.be.a 'string'
      done()

  it 'should get data from an acess token', ->
    data = testManager.getAccessTokenData sampleDataAccessToken
    data.should.deep.equal sampleData

  it 'should check that the access token is valid', ->
    getDataFromInvalidToken = ->
      testManager.getAccessTokenData invalidToken
    getDataFromInvalidToken.should.throw Error, /invalid/i

  it 'should check that the access token has not expired', ->
    getDataFromExpiredToken = ->
      testManager.getAccessTokenData expiredToken
    getDataFromExpiredToken.should.throw Error, /expired/i
