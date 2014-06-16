# Module dependencies
DynamoDbModel = require '../../src/dynamodb-datastore/model'

# Mocks
Mocks = require './mock-connection'
Data = require './mock-data'

updateKeys = Data.updateKeys
{tableName, keys} = Data.definition
{expectedKeys, expectedPut, expectedUpdate} = Data
responseData = Data.responsePutData

# Valid model
connection = Mocks.ValidConnection responseData
ValidModel = DynamoDbModel.extend connection, tableName, keys

# Error model
connection = Mocks.ErrorConnection()
ErrorModel = DynamoDbModel.extend connection, tableName, keys

# Check table model
connection = Mocks.CheckTableConnection tableName, responseData
CheckTableModel = DynamoDbModel.extend connection, tableName, keys

# Check keys model
connection = Mocks.CheckKeysConnection expectedKeys, updateKeys, responseData
CheckKeysModel = DynamoDbModel.extend connection, tableName, keys

# Check item model
connection = Mocks.CheckContentsConnection expectedPut, expectedUpdate, null
CheckContentsModel = DynamoDbModel.extend connection, tableName, keys

# Exports
module.exports.ValidModel = ValidModel
module.exports.ErrorModel = ErrorModel
module.exports.CheckTableModel = CheckTableModel
module.exports.CheckKeysModel = CheckKeysModel
module.exports.CheckContentsModel = CheckContentsModel
