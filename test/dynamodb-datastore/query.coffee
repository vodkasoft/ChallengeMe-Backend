# Test dependencies
chai = require 'chai'
should = chai.should()

# Mocks
DynamoDbModel = require '../../src/dynamodb-datastore/model'
{ ErrorModel} = require './mock-model'
Mocks = require './mock-connection'
Data = require './mock-data'

# Module to test
DynamoDbQuery = require '../../src/dynamodb-datastore/query'

# Sample response
response =
  Count: 3,
  Items: [
      { Id: {N: '1'}, FirstName: {S: 'John'}, LastName: {S: 'Doe'}}
      { Id: {N: '2'}, FirstName: {S: 'Jane'}, LastName: {S: 'Doe'}}
      { Id: {N: '3'}, FirstName: {S: 'John'}, LastName: {S: 'Black'}}
  ]

# Valid model
{tableName, keys} = Data.definition
connection = Mocks.ValidConnection response
ValidModel = DynamoDbModel.extend connection, tableName, keys

################################################################################
# DynamoDb Query                                                               #
################################################################################

describe 'DynamoDB Query', ->

  it 'should create an equal to constraint', ->
    query = new DynamoDbQuery ValidModel
    query.equalTo 'Sample', 'value'
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{S: 'value'}]
          ComparisonOperator: 'EQ'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a greater than constraint', ->
    query = new DynamoDbQuery ValidModel
    query.greaterThan 'Sample', 1
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}]
          ComparisonOperator: 'GT'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a greater than or equal to constraint', ->
    query = new DynamoDbQuery ValidModel
    query.greaterThanOrEqualTo 'Sample', 1
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}]
          ComparisonOperator: 'GE'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a less than constraint', ->
    query = new DynamoDbQuery ValidModel
    query.lessThan 'Sample', 1
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}]
          ComparisonOperator: 'LT'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a less than or equal to constraint', ->
    query = new DynamoDbQuery ValidModel
    query.lessThanOrEqualTo 'Sample', 1
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}]
          ComparisonOperator: 'LE'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a null constraint', ->
    query = new DynamoDbQuery ValidModel
    query.null 'Sample'
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          ComparisonOperator: 'NULL'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a contains constraint', ->
    query = new DynamoDbQuery ValidModel
    query.contains 'Sample', 1
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}]
          ComparisonOperator: 'CONTAINS'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create an in constraint', ->
    query = new DynamoDbQuery ValidModel
    query.in 'Sample', [1, 2, 3]
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}, {N: '2'}, {N: '3'}]
          ComparisonOperator: 'IN'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a between constraint', ->
    query = new DynamoDbQuery ValidModel
    query.between 'Sample', 1, 2
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{N: '1'}, {N: '2'}]
          ComparisonOperator: 'BETWEEN'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create a begins with constraint', ->
    query = new DynamoDbQuery ValidModel
    query.beginsWith 'Sample', 'hi'
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      KeyConditions:
        Sample:
          AttributeValueList: [{S: 'hi'}]
          ComparisonOperator: 'BEGINS_WITH'
    query.getQuery().should.deep.equal expectedQuery

  it 'should create an limit constraint', ->
    query = new DynamoDbQuery ValidModel
    query.limit 5
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      Limit: 5
    query.getQuery().should.deep.equal expectedQuery

  it 'should allow to add an index', ->
    query = new DynamoDbQuery ValidModel
    query.useIndex 'Id'
    expectedQuery =
      TableName: Data.definition.tableName
      Select: 'ALL_ATTRIBUTES'
      IndexName: 'Id'
    query.getQuery().should.deep.equal expectedQuery

  ############################################################################
  # query.not                                                                #
  ############################################################################

  describe 'query.not', ->

    it 'should create an not equal to constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.equalTo 'Sample', 'value'
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{S: 'value'}]
            ComparisonOperator: 'NE'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not greater than constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.greaterThan 'Sample', 1
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{N: '1'}]
            ComparisonOperator: 'LE'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not greater than or equal to constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.greaterThanOrEqualTo 'Sample', 1
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{N: '1'}]
            ComparisonOperator: 'LT'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not less than constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.lessThan 'Sample', 1
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{N: '1'}]
            ComparisonOperator: 'GE'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not less than or equal to constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.lessThanOrEqualTo 'Sample', 1
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{N: '1'}]
            ComparisonOperator: 'GT'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not null constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.null 'Sample'
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            ComparisonOperator: 'NOT_NULL'
      query.getQuery().should.deep.equal expectedQuery

    it 'should create a not contains constraint', ->
      query = new DynamoDbQuery ValidModel
      query.not.contains 'Sample', 1
      expectedQuery =
        TableName: Data.definition.tableName
        Select: 'ALL_ATTRIBUTES'
        KeyConditions:
          Sample:
            AttributeValueList: [{N: '1'}]
            ComparisonOperator: 'NOT_CONTAINS'
      query.getQuery().should.deep.equal expectedQuery

  ############################################################################
  # query.find                                                               #
  ############################################################################

  describe 'query.find', ->

    it 'should construct a Model item from the data retrieved', (done) ->
      query = new DynamoDbQuery ValidModel
      query.find (error, items) ->
        # console.log 'Item: ', items[0]
        should.not.exist error
        should.exist items
        items.length.should.equal response.Count
        firstName = items[0].get 'FirstName'
        firstName.should.equal 'John'
        done()

    it 'should not mark the constructed Model as new', (done) ->
      query = new DynamoDbQuery ValidModel
      query.find (error, items) ->
        should.not.exist error
        should.exist items
        isNew = items[0].isNew()
        isNew.should.be.false
        done()

    it 'should not mark the constructed Model as editted', (done) ->
      query = new DynamoDbQuery ValidModel
      query.find (error, items) ->
        should.not.exist error
        should.exist items
        isEditted = items[0].isEditted()
        isEditted.should.be.false
        done()

    it 'should catch and pass errors in the query operation', (done) ->
      query = new DynamoDbQuery ErrorModel
      query.find (error) ->
        should.exist error
        done()
