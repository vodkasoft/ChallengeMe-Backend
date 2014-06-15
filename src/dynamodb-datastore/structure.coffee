# Creates a DynamoDB array structure
# @params {Array} array Array from which to derive the DynamoDB array structure
# @returns {Object} A DynamoDB array structrure
createDynamoDbArrayStructure = (array) ->
  isStringArray = false
  invalidElement = false
  valueArray = for element in array
    elementType = typeof element
    if elementType is 'string'
      isStringArray = true
      element
    else if elementType is 'number'
      element.toString()
    else
      invalidElement = true
      break
  if invalidElement
    S: JSON.stringify array
  if isStringArray
    SS: valueArray
  else
    NS: valueArray

# Creates a DynamoDB structure
# @params {Object} object Data from which to derive the DynamoDB structure
# @returns {Object} A DynamoDB structrure
createDynamoDbStructure = (object) ->
  type = typeof object
  if type is 'number'
    return N: object.toString()
  if type is 'string'
    return S: object
  if Array.isArray object
    return createDynamoDbArrayStructure object
  return S: JSON.stringify object

# Exports
module.exports.createDynamoDbStructure = createDynamoDbStructure
