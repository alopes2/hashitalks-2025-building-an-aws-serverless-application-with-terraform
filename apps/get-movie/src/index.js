import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';

const tableName = process.env.TABLE_NAME;

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const movieID = event.pathParameters?.movieID;

  if (!movieID) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Movie ID missing',
      }),
    };
  }

  console.log('Getting movie with ID ', movieID);

  const command = new GetCommand({
    TableName: tableName,
    Key: {
      ID: movieID.toString(),
    },
  });

  try {
    const dynamoResponse = await docClient.send(command);
    if (!dynamoResponse.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: 'Movie not found',
        }),
      };
    }

    const body = {
      title: dynamoResponse.Item.Title,
      rating: dynamoResponse.Item.Rating,
      id: dynamoResponse.Item.ID,
    };

    body.genres = Array.from(dynamoResponse.Item.Genres);

    const response = {
      statusCode: 200,
      body: JSON.stringify(body),
    };

    return response;
  } catch (e) {
    console.log(e);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: e.message,
      }),
    };
  }
};
