# Test dependencies
chai = require 'chai'
should = chai.should()

# Module to test
DynamoDbModel = require '../../src/dynamodb-datastore/model'

# Mocks
MockModels = require './mock-model'
Data = require './mock-data'

################################################################################
# DynamoDb Model                                                               #
################################################################################

describe 'DynamoDB Model', ->

  @timeout 500

  it 'should create an empty inner object', ->
    model = new MockModels.ValidModel()
    objectString = model.toString()
    should.exist objectString
    objectString.should.equal '{}'

  it 'should set an object as new when created', ->
    model = new MockModels.ValidModel()
    model.isNew().should.be.true

  it 'should set attributes passsed in constructor to object', ->
    model = new MockModels.ValidModel({one: 1, hello: 'hello'})
    model.get('one').should.equal 1
    model.get('hello').should.equal 'hello'

  it 'should set attribute values', ->
    model = new MockModels.ValidModel()
    model.set 'number', 5
    number = model.get 'number'
    number.should.equal 5

  it 'should change the editted state after setting an attribute', ->
    model = new MockModels.ValidModel()
    model.isEditted().should.be.false
    model.set('sample', 1)
    model.isEditted().should.be.true

  it 'should be able to mark the value as new or not new', ->
    model = new MockModels.ValidModel()
    model.isNew().should.be.true
    model.setNew false
    model.isNew().should.be.false

  it 'should be able to mark the value as editted or not editted', ->
    model = new MockModels.ValidModel()
    model.set 'Sample', 1
    model.isEditted().should.be.true
    model.setEditted false
    model.isEditted().should.be.false

  ############################################################################
  # model.has                                                                #
  ############################################################################

  describe 'model.has', ->

    it 'should consider non null values as set', ->
      model = new MockModels.ValidModel()
      model.set 'example', 1
      result = model.has 'example'
      result.should.be.true

    it 'should consider attributes with value zero as set', ->
      model = new MockModels.ValidModel()
      model.set 'example', 0
      result = model.has 'example'
      result.should.be.true

    it 'should not consider inexistent values as set', ->
      model = new MockModels.ValidModel()
      result = model.has 'example'
      result.should.be.false

    it 'should consider undefined values as not set', ->
      model = new MockModels.ValidModel()
      model.set undefined
      result = model.has 'example'
      result.should.be.false

    it 'should consider null values as not set', ->
      model = new MockModels.ValidModel()
      model.set null
      result = model.has 'example'
      result.should.be.false

  ############################################################################
  # Model.getItemByKeys                                                      #
  ############################################################################

  describe 'Model.getItemByKeys', ->

    it 'should get an item by its keys', (done) ->
      MockModels.ValidModel.getItemByKeys Data.keys, (error, item) ->
        should.not.exist error
        should.exist item
        done()

    it 'should detect and pass errors', (done) ->
      MockModels.ErrorModel.getItemByKeys Data.keys, (error, item) ->
        should.exist error
        should.not.exist item
        done()

    it 'should use the subclass\' table name', (done) ->
      MockModels.CheckTableModel.getItemByKeys Data.keys, (error, item) ->
        done()

    it 'should use the provided keys', (done) ->
      MockModels.CheckKeysModel.getItemByKeys Data.keys, (error, item) ->
        done()

    it 'should pass the item to the caller', (done) ->
      MockModels.ValidModel.getItemByKeys Data.keys, (error, item) ->
        should.not.exist error
        should.exist item
        expectedJson = Data.expectedPutDataJson
        actualJson = item.toString()
        actualJson.should.equal expectedJson
        done()

  ############################################################################
  # Model.deleteItemByKeys                                                   #
  ############################################################################

  describe 'Model.deleteItemByKeys', ->

    it 'should delete an item by its keys', (done) ->
      MockModels.ValidModel.deleteItemByKeys Data.keys, (error) ->
        should.not.exist error
        done()

    it 'should detect and pass errors', (done) ->
      MockModels.ErrorModel.deleteItemByKeys Data.keys, (error) ->
        should.exist error
        done()

    it 'should use the subclass\' table name', (done) ->
      MockModels.CheckTableModel.deleteItemByKeys Data.keys, (error) ->
        done()

    it 'should use the provided keys', (done) ->
      MockModels.CheckKeysModel.deleteItemByKeys Data.keys, (error) ->
        done()

  ############################################################################
  # model.delete                                                             #
  ############################################################################

  it 'should not delete an object if it is new', (done) ->
    model = new MockModels.ValidModel()
    for key, value of Data.keys
      model.set key, value
    model.isNew().should.be.true
    model.delete (error) ->
      should.exist error
      done()

  it 'should delete an object if it is not new', (done) ->
    model = new MockModels.ValidModel()
    for key, value of Data.keys
      model.set key, value
    model.setNew false
    model.delete (error) ->
      should.not.exist error
      done()

  it 'should delete the item under the subclass\' table name', (done) ->
    model = new MockModels.CheckTableModel()
    for key, value of Data.keys
      model.set key, value
    model.setNew false
    model.delete (error) ->
      should.not.exist error
      done()

  it 'should catch errors in the delete operation', (done) ->
    model = new MockModels.ErrorModel()
    for key, value of Data.keys
      model.set key, value
    model.setNew false
    model.delete (error) ->
      should.exist error
      done()

  it 'should not delete the item if it has no values for the keys', (done) ->
    model = new MockModels.ValidModel()
    model.setNew false
    model.delete (error) ->
      should.exist error
      done()

  it 'should use the item\'s keys when deleteing', (done) ->
    model = new MockModels.CheckKeysModel()
    for key, value of Data.keys
      model.set key, value
    model.setNew false
    model.delete (error) ->
      should.not.exist error
      done()

  ############################################################################
  # model.save                                                               #
  ############################################################################

  describe 'model.save', ->

    it 'should save an object if it is new and editted', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.isNew().should.be.true
      model.isEditted().should.be.true
      model.save (error) ->
        should.not.exist error
        done()

    it 'should save an object if it is new and not editted', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.isNew().should.be.true
      model.setEditted false
      model.save (error) ->
        should.not.exist error
        done()

    it 'should save an object if it is not new and editted', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.isEditted().should.be.true
      model.save (error) ->
        should.not.exist error
        done()

    it 'should not save an object if it is neither new nor editted', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.save (error) ->
        should.exist error
        done()

    it 'should save the item under the subclass\' table name', (done) ->
      model = new MockModels.CheckTableModel()
      for key, value of Data.keys
        model.set key, value
      model.isNew().should.be.true
      model.save (error) ->
        should.not.exist error
        done()

    it 'should catch errors in the save operation', (done) ->
      model = new MockModels.ErrorModel()
      for key, value of Data.keys
        model.set key, value
      model.isNew().should.be.true
      model.save (error) ->
        should.exist error
        done()

    it 'should not save the item if it has no values for the keys', (done) ->
      model = new MockModels.ValidModel()
      model.isNew().should.be.true
      model.save (error) ->
        should.exist error
        done()

    it 'should use the item\'s values when saving', (done) ->
      model = new MockModels.CheckContentsModel()
      for key, value of Data.requestPutData
        model.set key, value
      model.isNew().should.be.true
      model.save (error) ->
        should.not.exist error
        done()

    it 'should mark an item as not new after being saved', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.isNew().should.be.true
      model.save (error) ->
        model.isNew().should.be.false
        done()

    it 'should mark an item as not new after being saved', (done) ->
      MockModels.ValidModel.getItemByKeys Data.keys, (error, item) ->
        item.set 'example', 2
        item.isEditted().should.be.true
        item.save (error) ->
          item.isEditted().should.be.false
          done()

  ############################################################################
  # model.update                                                             #
  ############################################################################

  describe 'model.update', ->

    it 'should not update an object marked as new', (done) ->
      model = new MockModels.ValidModel()
      model.update {attr: 'newValue'}, (error) ->
        should.exist error
        done()

    it 'should not update an object marked as editted', (done) ->
      model = new MockModels.ValidModel()
      model.set 'attr', 'oldValue'
      model.setNew false
      model.isEditted().should.be.true
      model.update {attr: 'newValue'}, (error) ->
        should.exist error
        done()

    it 'should not mark the item as new or editted after update', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update {attr: 'newValue'}, (error) ->
        should.not.exist error
        model.isEditted().should.be.false
        done()

    it 'should not update if attributes is null', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update null, (error) ->
        should.exist error
        done()

    it 'should not update if no attributes are passed', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update {}, (error) ->
        should.exist error
        done()

    it 'should update single attributes', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.set 'attr', 'oldValue'
      model.setNew false
      model.setEditted false
      model.update {attr: 'newValue'}, (error) ->
        should.not.exist error
        attributeValue = model.get 'attr'
        attributeValue.should.equal 'newValue'
        done()

    it 'should update multiple attributes', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.set 'firstName', 'Jane'
      model.set 'lastName', 'Doe'
      model.setNew false
      model.setEditted false
      model.update {firstName: 'John', lastName: 'Black'}, (error) ->
        should.not.exist error
        firstName = model.get 'firstName'
        lastName = model.get 'lastName'
        firstName.should.equal 'John'
        lastName.should.equal 'Black'
        done()

    it 'should create attributes if they do not exist locally', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update {attr: 'newValue'}, (error) ->
        should.not.exist error
        attributeValue = model.get 'attr'
        should.exist attributeValue
        attributeValue.should.equal 'newValue'
        done()

    it 'should catch errors in the update operation', (done) ->
      model = new MockModels.ErrorModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.update {attr: 'newValue'}, (error) ->
        should.exist error
        done()

    it 'should not modify local values if the update fails', (done) ->
      model = new MockModels.ErrorModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.set 'attr', 'oldValue'
      model.setEditted false
      model.update {attr: 'newValue'}, (error) ->
        should.exist error
        attributeValue = model.get 'attr'
        attributeValue.should.equal 'oldValue'
        done()

    it 'should update the item under the subclass\' table name', (done) ->
      model = new MockModels.CheckTableModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update {attr: 'value'}, (error) ->
        should.not.exist error
        done()

    it 'should use the item\'s keys when updating', (done) ->
      model = new MockModels.CheckKeysModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update {attr: 'value'}, (error) ->
        should.not.exist error
        done()

    it 'should allow to update the values for the keys', (done) ->
      model = new MockModels.ValidModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      key = Object.keys(Data.keys)[0]
      newValue = Data.keys[key] + 1
      updateAttributes = {}
      updateAttributes[key] = newValue
      model.update updateAttributes, (error) ->
        should.not.exist error
        keyValue = model.get key
        should.exist keyValue
        keyValue.should.equal newValue
        done()

    it 'should use the attributes and values passed in the call', (done) ->
      model = new MockModels.CheckContentsModel()
      for key, value of Data.keys
        model.set key, value
      model.setNew false
      model.setEditted false
      model.update Data.updateData, (error) ->
        should.not.exist error
        done()
