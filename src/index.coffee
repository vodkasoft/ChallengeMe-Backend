# Module dependencies
AWS = require 'aws-sdk'
bodyParser = require 'body-parser'
compression = require 'compression'
cors = require 'cors'
endpoints = require './endpoints'
express = require 'express'
http = require 'http'
request = require 'request'
AccessTokenManager = require './access-token'
DataAccess = require './data-access'
DynamoDb = require './dynamodb-datastore'
FacebookAuthProvider = require './facebook-auth'

# Application
application = express()

# Enable CORS
application.use cors()

# Disable powered by header
application.disable 'x-powered-by'

# Middleware
application.use bodyParser.json()
application.use compression()

# AWS configuration
AWS.config.region = 'us-west-2'
dynamodb = new AWS.DynamoDB()

# Auth Provider
facebookAppSecret = '38164bbff5645fea77ec642f55153c61'
facebookAuthProvider = new FacebookAuthProvider request, facebookAppSecret

# Access Token Manager
accessTokenKey = 'a61fac33-ae1a-4076-b8e8-c883e1a99bb4'
accessTokenSalt = '024a3728-4c97-404d-b7e9-e2528a6bde94'
accessTokenManager = new AccessTokenManager accessTokenKey, accessTokenSalt

# Data Access
models =
  Client: DynamoDb.Model.extend dynamodb, 'Client', {Id: 'S'}
  User: DynamoDb.Model.extend dynamodb, 'User', {Id: 'S'}
  Challenge: DynamoDb.Model.extend dynamodb, 'Challenge', {Id: 'S'}
dataAccess = new DataAccess models, DynamoDb.Query

# Endpoints
endpointsRouter = express.Router()
endpointsOptions =
  dataAccess: dataAccess
  tokenManager: accessTokenManager
  authProvider: facebookAuthProvider
endpoints.configureRouter endpointsRouter, endpointsOptions
application.use '/', endpointsRouter

# Error handling
application.use (error, request, response, next) ->
  response.send 500, {error: {status: 500, message: 'Internal error'}}

# Create server and start listening
http.createServer(application).listen 80
