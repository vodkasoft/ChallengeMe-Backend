# Module dependencies
{createDynamoDbStructure} = require './structure'

# Base model for entities stored in DynamoDB
class DynamoDbModel

  # Deletes an object from the datastore
  # @param {Object} keys The keys of the item on the datastore
  # @param {Function} callback Funciton to handle the result or error
  @deleteItemByKeys = (keys, callback) ->
    for requiredKey of @_keys
      if not keys[requiredKey]
        return callback new Error "Missing value of key '#{requiredKey}'"
    dynamoDbKeys = {}
    for key, value of keys
      dynamoDbKeys[key] = createDynamoDbStructure value
    params =
      TableName: @_tableName
      Key: dynamoDbKeys
    @_dynamodbConnection.deleteItem params, (error) ->
      callback error

  # Extends the default model
  # @param {Object} dynamodbConnection DynamoDB connection to query
  # @param {string} tableName Name of the table registered in DynamoDB
  # @param {Object} keys The keys of the item on the datastore with types
  @extend = (dynamodbConnection, tableName, keys) ->
    class Model extends DynamoDbModel
      @_dynamodbConnection = dynamodbConnection
      @_tableName = tableName
      @_keys = keys

  # Retrieves an object from the datastore
  # @param {Object} keys The keys of the item on the datastore
  # @param {Function} callback Funciton to handle the data or error
  @getItemByKeys = (keys, callback) ->
    dynamoDbKeys = {}
    for key, value of keys
      dynamoDbKeys[key] = createDynamoDbStructure value
    params =
      TableName: @_tableName
      Key: dynamoDbKeys
    itemType = this
    @_dynamodbConnection.getItem params, (error, data) ->
      if error
        return callback error
      parsedData = {}
      for key, value of data.Item
        attributeStructure = value
        type = Object.keys(attributeStructure)[0]
        parsedData[key] = attributeStructure[type]
        if type is not 'S'
          parsedData[key] = JSON.parse parsedData[key]
      item = new itemType parsedData
      item.setNew false
      item.setEditted false
      callback null, item

  # Creates an DynamoDbModel
  # @param {object} properties Attributes and value for the object (optional)
  constructor: (properties) ->
    @_innerObject = {}
    for attribute, value of properties
      @set attribute, value
    @_new = true
    @_editted = false

  # Deletes the object from the datastore
  # @param {Function} callback Funciton to handle the result or error
  delete: (callback) ->
    if @isNew()
      return callback new Error 'Object not in datastore'
    itemKeys = {}
    for key of @constructor._keys
      itemKeys[key] = @get key
    @constructor.deleteItemByKeys itemKeys, callback

  # Checks if object has a value for an attribute
  # @param {string} attribute The name of the attribute
  # @returns {boolean} True if the object has the attribute; false otherwise
  has: (attribute) ->
    @get(attribute)?

  # Gets the value of an attribute
  # @param {string} attribute The name of the attribute
  # @returns {Object} The value of the attribute
  get: (attribute) ->
    @_innerObject[attribute]

  # Checks if an object has been editted
  # @returns {boolean} True if the object has not been editted; false otherwise
  isEditted: ->
    @_editted

  # Checks if an object has not been saved to the datstore
  # @returns {boolean} True if the object has not been saved; false otherwise
  isNew: ->
    @_new

  # Saves the object to the datastore
  # @param {Function} callback Funciton to handle id or error
  save: (callback) ->
    if not (@isNew() or @isEditted())
      return callback new Error 'Object already saved to datstore'
    for requiredKey of @constructor._keys
      if not @has requiredKey
        return callback new Error "Missing value of key '#{requiredKey}'"
    params =
      TableName: @constructor._tableName
      Item: {}
    for key, value of @_innerObject
      params.Item[key] = createDynamoDbStructure value
    item = this
    @constructor._dynamodbConnection.putItem params, (error) ->
      if error
        return callback error
      item.setNew false
      item.setEditted false
      callback null

  # Sets the value of an attribute
  # @param {string} attribute The name of the attribute
  # @param {Object} value The value of the attribute
  # @returns {Object} The new value of the attribute
  set: (attribute, value) ->
    @_innerObject[attribute] = value
    @_editted = true

  # Changes the editted state for the item
  # @param {boolean} value The new value for the editted flag
  # @returns {boolean} The new value of the edtted flag
  setEditted: (value) ->
    @_editted = value

  # Changes the new state for the item
  # @param {boolean} value The new value for the new flag
  # @returns {boolean} The new value of the new flag
  setNew: (value) ->
    @_new = value

  # Creates a JSON string with the object's data
  # @returns {string} JSON representation of the object
  toString: ->
    JSON.stringify @_innerObject

  # Updates the values for the item in the datastore
  # @param {object} attributes New attributes and values for the item
  # @param {Function} callback Funciton to handle id or error
  update: (attributes, callback) ->
    if @isNew()
      return callback new Error 'Cannot update an item that has not been saved'
    if @isEditted()
      return callback new Error 'Cannot update an item that has been modified'
    if not attributes or Object.keys(attributes).length < 1
      return callback new Error 'No attributes to update'
    dynamoDbKeys = {}
    for key of @constructor._keys
      attributeValue = if attributes[key]
        attributes[key]
        attributes[key]
      else
        @get key
      if not attributeValue
        callback new Error "Missing key '#{key}'"
      dynamoDbKeys[key] = createDynamoDbStructure attributeValue
    dynamoDbAttributes = {}
    for key, value of attributes
      if key not in @constructor._keys
        dynamoValue = createDynamoDbStructure value
        dynamoDbAttributes[key] =
          Action: 'PUT'
          Value: dynamoValue
    params =
      TableName: @constructor._tableName
      Key: dynamoDbKeys
      AttributeUpdates: dynamoDbAttributes
    item = this
    @constructor._dynamodbConnection.updateItem params, (error) ->
      if error
        return callback error
      for key, value of attributes
        item.set key, value
      item.setEditted false
      return callback null

# Exports
module.exports = DynamoDbModel
