#!/bin/bash

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export EDGE_PORT=4566
export LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-ex"

# Create zip for each Lambda
zip -j authorizer.zip lambdas/authorizer/index.js
zip -j connection.zip lambdas/connection-manager/index.js
(cd lambdas/validator && zip -r ../../validator.zip .)

# Create Lambdas
awslocal lambda create-function --function-name Authorizer \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://authorizer.zip --role $LAMBDA_ROLE

awslocal lambda create-function --function-name ConnectionManager \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://connection.zip --role $LAMBDA_ROLE

awslocal lambda create-function --function-name Validator \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://validator.zip --role $LAMBDA_ROLE

# Create REST API
api_id=$(awslocal apigateway create-rest-api \
  --name test-api \
  --query 'id' --output text)

# Get root resource ID
root_id=$(awslocal apigateway get-resources --rest-api-id $api_id --query 'items[?path==`/`].id' --output text)

# Create resource for validator
resource_id=$(awslocal apigateway create-resource \
  --rest-api-id $api_id \
  --parent-id $root_id \
  --path-part "recordStep" \
  --query 'id' --output text)

# Create POST method
awslocal apigateway put-method \
  --rest-api-id $api_id \
  --resource-id $resource_id \
  --http-method POST \
  --authorization-type NONE

# Create integration
awslocal apigateway put-integration \
  --rest-api-id $api_id \
  --resource-id $resource_id \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:Validator/invocations

# Deploy API
awslocal apigateway create-deployment \
  --rest-api-id $api_id \
  --stage-name dev

echo "✅ REST API URL: http://localhost:4566/restapis/$api_id/dev/_user_request_/recordStep"
echo "✅ Test with: curl -X POST http://localhost:4566/restapis/$api_id/dev/_user_request_/recordStep -H 'Content-Type: application/json' -d '{\"sessionId\": \"test-session-01\", \"payload\": {\"type\": \"click\", \"target\": \"#login-button\"}}'" 