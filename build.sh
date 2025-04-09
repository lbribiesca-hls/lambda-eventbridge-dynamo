#!/bin/bash

set -e

# CONFIG
STACK_NAME="lambda-eventbridge-dynamo-stack"
REGION="us-east-1"
BUCKET_NAME="lambda-deploy-$(uuidgen | cut -d'-' -f1)"
TEMPLATE_FILE="template.yaml"
PACKAGED_TEMPLATE="packaged.yaml"
ZIP_FILE="function.zip"

echo "📁 Bucket S3 para despliegue: $BUCKET_NAME"

# Guardar config en .env
cat > .env <<EOF
BUCKET_NAME=$BUCKET_NAME
REGION=$REGION
STACK_NAME=$STACK_NAME
EOF

# Crear bucket
echo "🔧 Creando bucket S3..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo "⚠️ Bucket ya existe."

# Empaquetar Lambda
echo "📦 Empaquetando Lambda..."
cd lambda
npm install
cd ..
zip -r "$ZIP_FILE" lambda/* > /dev/null

# Subir a S3
echo "📤 Subiendo ZIP a S3..."
aws s3 cp "$ZIP_FILE" "s3://$BUCKET_NAME/lambda/$ZIP_FILE"

# Empaquetar CloudFormation
echo "📦 Empaquetando plantilla..."
aws cloudformation package \
  --template-file "$TEMPLATE_FILE" \
  --s3-bucket "$BUCKET_NAME" \
  --output-template-file "$PACKAGED_TEMPLATE"

# Desplegar
echo "🚀 Desplegando stack..."
aws cloudformation deploy \
  --template-file "$PACKAGED_TEMPLATE" \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Despliegue completo."
