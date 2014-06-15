# Moudle dependencies
{createDynamoDbStructure} = require './structure'

# Creates a function call with the negated mode enabled
# @param {Object} query Query that owns the method
# @param {string} method Name of the method
# @returns {Function} Method using the negated mode
callNot = (query, method) ->
  () ->
    query._pendingNot = true
    query[method].apply query, arguments

# A query constructor and executor for DynamoDB
class DynamoDbQuery

  # Creates a 'begins with' constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {string} value Value to match
  beginsWith: (attribute, value) ->
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: 'BEGINS_WITH'
    return

  # Creates a 'between' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number | string} lowerLimit Lower bound
  # @param {number | string} upperLimit Upper bound
  between: (attribute, lowerLimit, upperLimit) ->
    lowerLimit = createDynamoDbStructure lowerLimit
    upperLimit = createDynamoDbStructure upperLimit
    @_conditions[attribute] =
      AttributeValueList: [lowerLimit, upperLimit]
      ComparisonOperator: 'BETWEEN'
    return

  # Creates a DynamoDbQuery
  # @param {object} Model DynamoDbModel to query
  constructor: (Model) ->
    @_Model = Model
    @_conditions = {}
    @_pendingNot = false
    query = this
    @not =
      contains: callNot query, 'contains'
      equalTo: callNot query, 'equalTo'
      greaterThan: callNot query, 'greaterThan'
      greaterThanOrEqualTo: callNot query, 'greaterThanOrEqualTo'
      lessThan: callNot query, 'lessThan'
      lessThanOrEqualTo: callNot query, 'lessThanOrEqualTo'
      null: callNot query, 'null'

  # Creates a 'contains' constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number | string} value Value to match
  contains: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'NOT_CONTAINS'
    else
      operator = 'CONTAINS'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Creates an 'equal to' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number | string} value Value to match
  equalTo: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'NE'
    else
      operator = 'EQ'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Performs the query and retrieves an array of items
  # @param {Function} callback Function to handle items or error
  find: (callback) ->
    Model = @_Model
    connection = Model._dynamodbConnection
    connection.query @getQuery(), (error, data) ->
      if error
        return callback error
      parsedItems = for item in data.Items
        parsedData = {}
        for key, value of item
          attributeStructure = value
          type = Object.keys(attributeStructure)[0]
          parsedData[key] = attributeStructure[type]
          if type is not 'S'
            parsedData[key] = JSON.parse parsedData[key]
        modelItem = new Model(parsedData)
        modelItem.setNew false
        modelItem.setEditted false
        modelItem
      callback null, parsedItems

  # Gets the query that can be sent to DynamoDB
  # @returns {object} The raw query
  getQuery: ->
    tableName = @_Model._tableName
    query =
      TableName: tableName
      Select: 'ALL_ATTRIBUTES'
    if @_indexName
      query.IndexName = @_indexName
    if @_limit
      query.Limit = @_limit
    if Object.keys(@_conditions).length > 0
      query.KeyConditions = @_conditions
    query

  # Creates a 'greater than' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number} value Value to match
  greaterThan: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'LE'
    else
      operator = 'GT'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Creates a 'greater than or equal to' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number} value Value to match
  greaterThanOrEqualTo: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'LT'
    else
      operator = 'GE'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Creates an 'in' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {array} values Value set to match
  in: (attribute, values) ->
    valueList = for value in values
      createDynamoDbStructure value
    @_conditions[attribute] =
      AttributeValueList: valueList
      ComparisonOperator: 'IN'
    return

  # Creates a 'less than' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number} value Value to match
  lessThan: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'GE'
    else
      operator = 'LT'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Creates a 'less than or equal to' with constraint
  # @param {string} attribute Name of the attribute to filter
  # @param {number} value Value to match
  lessThanOrEqualTo: (attribute, value) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'GT'
    else
      operator = 'LE'
    @_conditions[attribute] =
      AttributeValueList: [createDynamoDbStructure value]
      ComparisonOperator: operator
    return

  # Sets a limit for the query
  # @param {number} limit The maximum number of items to retrieve
  limit: (limit) ->
    @_limit = limit
    return

  # Creates a 'null' constraint
  # @param {string} attribute Name of the attribute to filter
  null: (attribute) ->
    if @_pendingNot
      @_pendingNot = false
      operator = 'NOT_NULL'
    else
      operator = 'NULL'
    @_conditions[attribute] =
      ComparisonOperator: operator
    return

  # Creates a JSON representation of the query
  # @returns {string} JSON representation of the query
  toString: ->
    @getQuery().toString()

  # Sets the index that should be used in the query
  # @param {string} name The name of the index
  useIndex: (name) ->
    @_indexName = name
    return

# Exports
module.exports = DynamoDbQuery
