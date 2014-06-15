# Test dependencies
chai = require 'chai'
should = chai.should()

# Mock error message
MOCK_ERROR_MESSAGE = 'Mock error'
module.exports.mockErrorMessage = MOCK_ERROR_MESSAGE

# Valid connection
validResponse = (response) ->
  (params, callback) ->
    callback null, response

module.exports.ValidConnection = (response) ->
  getItem: validResponse {Item: response}
  putItem: validResponse response
  deleteItem: validResponse response
  updateItem: validResponse response
  query: validResponse response

# Error connection
errorResponse = (params, callback) ->
  callback new Error MOCK_ERROR_MESSAGE

module.exports.ErrorConnection = ->
  getItem: errorResponse
  putItem: errorResponse
  deleteItem: errorResponse
  updateItem: errorResponse
  query: errorResponse

# Check table connection
checkTableResponse = (tableName, response) ->
  (params, callback) ->
    should.exist params.TableName
    params.TableName.should.equal tableName
    handler = validResponse response
    handler params, callback

module.exports.CheckTableConnection = (tableName, response) ->
  getItem: checkTableResponse tableName, {Item: response}
  putItem: checkTableResponse tableName, response
  deleteItem: checkTableResponse tableName, response
  updateItem: checkTableResponse tableName, response

# Check keys connection
checkKeysResponse = (keys, response) ->
  (params, callback) ->
    should.exist params.Key
    params.Key.should.deep.equal keys
    handler = validResponse response
    handler params, callback

module.exports.CheckKeysConnection = (keys, updateKeys, response) ->
  getItem: checkKeysResponse keys, {Item: response}
  putItem: checkKeysResponse keys, response
  deleteItem: checkKeysResponse keys, response
  updateItem: checkKeysResponse updateKeys, response

# Chack item connection
checkContentsResponse = (attribute, expected, response) ->
  (params, callback) ->
    should.exist params[attribute]
    params[attribute].should.deep.equal expected
    handler = validResponse response
    handler params, callback

module.exports.CheckContentsConnection = (expectPut, expectUpdate, response) ->
  putItem: checkContentsResponse 'Item', expectPut, response
  updateItem: checkContentsResponse 'AttributeUpdates', expectUpdate, response
