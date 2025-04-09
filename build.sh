#!/bin/bash
set -e

# CONFIGURACIÓN
STACK_NAME="lambda-eventbridge-dynamo-stack"
REGION="us-east-1"
BUCKET_NAME="lambda-deploy-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
TEMPLATE_FILE="template.yaml"
PACKAGED_TEMPLATE="packaged.yaml"
ZIP_FILE="function.zip"

echo "📁 Bucket S3 para despliegue: $BUCKET_NAME"

# Guardar variables en .env para destroy.sh
cat > .env <<EOF
BUCKET_NAME=$BUCKET_NAME
REGION=$REGION
STACK_NAME=$STACK_NAME
EOF

# Crear bucket S3 con manejo especial para us-east-1
echo "🔧 Creando bucket S3: $BUCKET_NAME en $REGION"

if [ "$REGION" == "us-east-1" ]; then
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION"
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "✅ Bucket creado (si no falló arriba)."

# Esperar hasta que esté disponible
echo "⏳ Esperando que el bucket esté disponible..."
MAX_ATTEMPTS=10
SLEEP_INTERVAL=3
for attempt in $(seq 1 $MAX_ATTEMPTS); do
  if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
    echo "✅ Bucket disponible."
    break
  else
    echo "⏳ Intento $attempt/$MAX_ATTEMPTS: el bucket aún no está disponible..."
    sleep $SLEEP_INTERVAL
  fi
done

# Verificación final
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null; then
  echo "❌ El bucket no está disponible luego de varios intentos. Abortando."
  exit 1
fi

# Empaquetar Lambda
echo "📦 Empaquetando Lambda..."
cd lambda
npm install --force
cd ..
zip -r "$ZIP_FILE" lambda/* > /dev/null

# Subir a S3
echo "📤 Subiendo ZIP a S3..."
aws s3 cp "$ZIP_FILE" "s3://$BUCKET_NAME/lambda/$ZIP_FILE"

# Empaquetar plantilla CloudFormation
echo "📦 Empaquetando plantilla CloudFormation..."
aws cloudformation package \
  --template-file "$TEMPLATE_FILE" \
  --s3-bucket "$BUCKET_NAME" \
  --output-template-file "$PACKAGED_TEMPLATE"

# Desplegar stack
echo "🚀 Desplegando stack..."
aws cloudformation deploy \
  --template-file "$PACKAGED_TEMPLATE" \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_NAMED_IAM

echo "✅ Despliegue completado con éxito."
