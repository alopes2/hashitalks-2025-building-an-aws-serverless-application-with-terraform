import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { randomUUID } from 'crypto';

const tableName = process.env.TABLE_NAME;

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  let newMovie;
  try {
    newMovie = JSON.parse(event.body);
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Request body invalid',
      }),
    };
  }

  if (!newMovie) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Request body invalid',
      }),
    };
  }

  console.log('Received request: ', newMovie);

  newMovie.id = randomUUID();
  newMovie.genres = new Set(newMovie.genres);

  const command = new PutCommand({
    TableName: tableName,
    Item: {
      ID: newMovie.id,
      Title: newMovie.title,
      Rating: newMovie.rating,
      Genres: newMovie.genres,
    },
  });

  try {
    await docClient.send(command);

    const movie = {
      id: newMovie.id,
      title: newMovie.title,
      rating: newMovie.rating,
      genres: Array.from(newMovie.genres),
    };

    await publishEventToSNS(movie);

    const response = {
      statusCode: 201,
      body: JSON.stringify(movie),
    };

    return response;
  } catch (e) {
    console.log('Error calling PutItem: ', e);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: e.message,
      }),
    };
  }
};

async function publishEventToSNS(movie) {
  const snsClient = new SNSClient({});

  const eventName = 'MovieCreated';

  try {
    await snsClient.send(
      new PublishCommand({
        Message: JSON.stringify(movie),
        TopicArn: process.env.SNS_TOPIC_ARN,
        MessageAttributes: {
          Type: {
            DataType: 'String',
            StringValue: eventName,
          },
        },
      })
    );
  } catch (e) {
    console.warn(e);
  }
}
