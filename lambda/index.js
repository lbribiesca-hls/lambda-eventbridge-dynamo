const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const { v4: uuidv4 } = require("uuid");

const client = new DynamoDBClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  const id = uuidv4();
  const timestamp = new Date().toISOString();

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      id: { S: id },
      timestamp: { S: timestamp },
      eventData: { S: JSON.stringify(event) }
    }
  };

  try {
    await client.send(new PutItemCommand(params));
    console.log(`Evento guardado con ID ${id}`);
  } catch (err) {
    console.error("Error guardando en DynamoDB:", err);
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Evento procesado y guardado." }),
  };
};
