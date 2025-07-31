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

# Create WebSocket API
api_id=$(awslocal apigatewayv2 create-api \
  --name websocket-api \
  --protocol-type WEBSOCKET \
  --route-selection-expression '$request.body.action' \
  --query 'ApiId' --output text)

# Integrations
auth_int=$(awslocal apigatewayv2 create-integration --api-id $api_id \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:Authorizer/invocations \
  --integration-method POST --payload-format-version 2.0 \
  --query 'IntegrationId' --output text)

conn_int=$(awslocal apigatewayv2 create-integration --api-id $api_id \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:ConnectionManager/invocations \
  --integration-method POST --payload-format-version 2.0 \
  --query 'IntegrationId' --output text)

val_int=$(awslocal apigatewayv2 create-integration --api-id $api_id \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:Validator/invocations \
  --integration-method POST --payload-format-version 2.0 \
  --query 'IntegrationId' --output text)

# Routes
awslocal apigatewayv2 create-route --api-id $api_id --route-key '$connect' \
  --target integrations/$conn_int

awslocal apigatewayv2 create-route --api-id $api_id --route-key '$disconnect' \
  --target integrations/$conn_int

awslocal apigatewayv2 create-route --api-id $api_id --route-key 'recordStep' \
  --target integrations/$val_int

# Deploy
stage=$(awslocal apigatewayv2 create-deployment --api-id $api_id --query 'DeploymentId' --output text)
awslocal apigatewayv2 create-stage --api-id $api_id --stage-name dev --deployment-id $stage

echo "✅ WebSocket URL: ws://localhost:4566/$api_id/dev" 