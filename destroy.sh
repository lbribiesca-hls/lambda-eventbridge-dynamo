#!/bin/bash

set -e

# Cargar variables del .env
if [ -f .env ]; then
  source .env
else
  echo "❌ No se encontró el archivo .env. Ejecuta primero ./build.sh"
  exit 1
fi

echo "🗑️ Eliminando stack: $STACK_NAME"
aws cloudformation delete-stack \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo "⏳ Esperando a que se elimine el stack..."
aws cloudformation wait stack-delete-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"
echo "✅ Stack eliminado."

# Eliminar bucket
if [[ -n "$BUCKET_NAME" ]]; then
  echo "🧹 Eliminando bucket S3: $BUCKET_NAME"
  aws s3 rm "s3://$BUCKET_NAME" --recursive --region "$REGION"
  aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
  echo "✅ Bucket eliminado."
else
  echo "⚠️ No se detectó bucket."
fi

# Eliminar .env
rm -f .env

echo "🧼 Limpieza completa."
