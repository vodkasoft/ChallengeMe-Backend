# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
{createDynamoDbStructure} = require '../../src/dynamodb-datastore/structure'

################################################################################
# DynamoDb Structure                                                           #
################################################################################

describe 'DynamoDB Structure', ->

  it 'should construct a structure form a string', ->
    structure = createDynamoDbStructure 'hello'
    structure.should.deep.equal {S: 'hello'}

  it 'should construct a structure form a number', ->
    structure = createDynamoDbStructure [18, 21]
    structure.should.deep.equal {NS: ['18','21']}

  it 'should construct a structure form a string array', ->
    structure = createDynamoDbStructure ['hello', 'hi']
    structure.should.deep.equal {SS: ['hello', 'hi']}

  it 'should construct a structure form a number array', ->
    structure = createDynamoDbStructure 21
    structure.should.deep.equal {N: '21'}

  it 'should construct a structure form an object', ->
    structure = createDynamoDbStructure {one: 1}
    structure.should.deep.equal {S: JSON.stringify({one: 1})}
