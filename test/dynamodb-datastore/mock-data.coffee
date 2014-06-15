# Sample model definition
module.exports.definition =
  tableName: 'Sample'
  keys: {Id: 'N', Other: 'S'}

# Search keys
module.exports.keys =
  Id: 1
  Other: 'other'

# Sample put data
module.exports.requestPutData =
  Id: 1
  Other: 'other'
  FirstName: 'John'
  LastName: 'Doe'

module.exports.responsePutData =
  Id: {N: '1'}
  Other: {S: 'other'}
  FirstName: {S: 'John'}
  LastName: {S: 'Doe'}

module.exports.expectedPutDataJson = JSON.stringify {
  Id: '1'
  Other: 'other'
  FirstName: 'John'
  LastName: 'Doe'
}

# Sample update data
module.exports.updateData =
  ups: 25
  downs: 'none'
  FirstName: 'Jane'

# Expected keys
module.exports.expectedKeys =
  Id: {N: '1'}
  Other: {S: 'other'}

# Update keys
module.exports.updateKeys =
  Id: {N: '1'}
  Other: {S: 'other'}

# Expected put data
module.exports.expectedPut =
  Id: {N: '1'}
  Other: {S: 'other'}
  FirstName: {S: 'John'}
  LastName: {S: 'Doe'}

# Expected update data
module.exports.expectedUpdate =
  ups:
    Action: 'PUT'
    Value: {N: '25'}
  downs:
    Action: 'PUT'
    Value: {S: 'none'}
  FirstName:
    Action: 'PUT'
    Value: {S: 'Jane'}
