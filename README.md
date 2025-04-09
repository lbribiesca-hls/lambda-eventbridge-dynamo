# 🛰️ Lambda + EventBridge + DynamoDB (con CloudFormation)

Este proyecto despliega una arquitectura Serverless en AWS con:

- 🧠 AWS Lambda (Node.js): función que guarda eventos recibidos
- ⏰ Amazon EventBridge: dispara la Lambda cada minuto
- 📦 Amazon DynamoDB: almacena los eventos con id, timestamp y datos
- 🏗️ CloudFormation: infraestructura como código
- 🔁 Automatización: scripts para despliegue y destrucción total

## 📁 Estructura del proyecto

```
lambda-eventbridge-dynamo/
├── lambda/
│   ├── index.js
│   └── package.json
├── template.yaml
├── build.sh
├── destroy.sh
└── README.md
```

## 🚀 Despliegue automático

### 1. Requisitos previos

- AWS CLI configurado (`aws configure`)
- Node.js y npm instalados
- Permisos para crear: Lambda, DynamoDB, IAM Roles, EventBridge, S3

### 2. Ejecutar despliegue

```bash
chmod +x build.sh
./build.sh
```

## 🧪 Validación

- Verifica la función en Lambda
- Revisa los registros en DynamoDB
- Examina logs en CloudWatch

## 🗑️ Destruir los recursos

```bash
chmod +x destroy.sh
./destroy.sh
```

## 🛠️ Personalización

Edita:
- `rate(1 minute)` en template.yaml
- Lógica de la Lambda (lambda/index.js)
- Estructura de la tabla DynamoDB
