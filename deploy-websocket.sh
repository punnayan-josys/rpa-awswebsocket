#!/bin/bash

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export EDGE_PORT=4566
export LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-ex"

echo "🚀 Deploying WebSocket API Gateway..."

# Create zip for each Lambda
echo "📦 Creating Lambda packages..."
zip -j authorizer.zip lambdas/authorizer/index.js
(cd lambdas/connection-manager && zip -r ../../connection.zip .)
(cd lambdas/validator && zip -r ../../validator.zip .)

# Create Lambdas
echo "🔧 Creating Lambda functions..."
awslocal lambda create-function --function-name Authorizer \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://authorizer.zip --role $LAMBDA_ROLE

awslocal lambda create-function --function-name ConnectionManager \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://connection.zip --role $LAMBDA_ROLE

awslocal lambda create-function --function-name Validator \
  --runtime nodejs18.x --handler index.handler \
  --zip-file fileb://validator.zip --role $LAMBDA_ROLE

# Try to create WebSocket API
echo "🌐 Creating WebSocket API..."
api_id=$(awslocal apigatewayv2 create-api \
  --name websocket-api \
  --protocol-type WEBSOCKET \
  --route-selection-expression '$request.body.action' \
  --query 'ApiId' --output text 2>/dev/null)

if [ -z "$api_id" ] || [ "$api_id" = "null" ]; then
  echo "⚠️ WebSocket API creation failed. Creating REST API with WebSocket-like behavior..."
  
  # Fallback to REST API
  api_id=$(awslocal apigateway create-rest-api \
    --name websocket-fallback-api \
    --query 'id' --output text)
  
  # Get root resource ID
  root_id=$(awslocal apigateway get-resources --rest-api-id $api_id --query 'items[?path==`/`].id' --output text)
  
  # Create WebSocket-like endpoints
  echo "🔗 Creating WebSocket-like endpoints..."
  
  # Connect endpoint
  connect_resource=$(awslocal apigateway create-resource \
    --rest-api-id $api_id \
    --parent-id $root_id \
    --path-part "connect" \
    --query 'id' --output text)
  
  awslocal apigateway put-method \
    --rest-api-id $api_id \
    --resource-id $connect_resource \
    --http-method POST \
    --authorization-type NONE
  
  awslocal apigateway put-integration \
    --rest-api-id $api_id \
    --resource-id $connect_resource \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:ConnectionManager/invocations
  
  # Message endpoint
  message_resource=$(awslocal apigateway create-resource \
    --rest-api-id $api_id \
    --parent-id $root_id \
    --path-part "message" \
    --query 'id' --output text)
  
  awslocal apigateway put-method \
    --rest-api-id $api_id \
    --resource-id $message_resource \
    --http-method POST \
    --authorization-type NONE
  
  awslocal apigateway put-integration \
    --rest-api-id $api_id \
    --resource-id $message_resource \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:ConnectionManager/invocations
  
  # Deploy API
  awslocal apigateway create-deployment \
    --rest-api-id $api_id \
    --stage-name dev
  
  echo "✅ REST API with WebSocket-like behavior created!"
  echo "📡 Connect URL: http://localhost:4566/restapis/$api_id/dev/_user_request_/connect"
  echo "📡 Message URL: http://localhost:4566/restapis/$api_id/dev/_user_request_/message"
  
else
  echo "✅ WebSocket API created successfully!"
  
  # Create integrations
  echo "🔗 Creating integrations..."
  conn_int=$(awslocal apigatewayv2 create-integration --api-id $api_id \
    --integration-type AWS_PROXY \
    --integration-uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:ConnectionManager/invocations \
    --integration-method POST --payload-format-version 2.0 \
    --query 'IntegrationId' --output text)
  
  # Create routes
  echo "🛣️ Creating routes..."
  awslocal apigatewayv2 create-route --api-id $api_id --route-key '$connect' \
    --target integrations/$conn_int
  
  awslocal apigatewayv2 create-route --api-id $api_id --route-key '$disconnect' \
    --target integrations/$conn_int
  
  awslocal apigatewayv2 create-route --api-id $api_id --route-key '$default' \
    --target integrations/$conn_int
  
  # Deploy
  stage=$(awslocal apigatewayv2 create-deployment --api-id $api_id --query 'DeploymentId' --output text)
  awslocal apigatewayv2 create-stage --api-id $api_id --stage-name dev --deployment-id $stage
  
  echo "✅ WebSocket URL: ws://localhost:4566/$api_id/dev"
fi

echo ""
echo "🧪 Test the WebSocket connection:"
echo "1. Connect: curl -X POST http://localhost:4566/restapis/$api_id/dev/_user_request_/connect"
echo "2. Send message: curl -X POST http://localhost:4566/restapis/$api_id/dev/_user_request_/message \\"
echo "   -H 'Content-Type: application/json' \\"
echo "   -d '{\"action\": \"recordStep\", \"sessionId\": \"test\", \"payload\": {\"type\": \"click\", \"target\": \"#button\"}}'" 