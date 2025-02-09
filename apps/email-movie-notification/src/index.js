import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

const client = new SESClient({});

export const handler = async (event, context) => {
  const promises = [];
  for (const message of event.Records) {
    promises.push(processMessageAsync(message));
  }

  await Promise.all(promises);

  console.info('done');
};

async function processMessageAsync(message) {
  try {
    const eventType =
      message.messageAttributes['Type'].stringValue ?? 'MovieEvent';
    console.log(`Processing ${eventType} message ${message.body}`);

    await sendEmail(message);

    console.log(`Processed ${eventType} message ${message.body}`);
  } catch (err) {
    console.error('An error occurred');
    console.error(err);
  }
}

async function sendEmail(message) {
  const eventBody = JSON.parse(message.body);
  const subject = 'New Movie Added: ' + eventBody.title;
  const body =
    'A new movie was added!\n' +
    'ID: ' +
    eventBody.id +
    '\n' +
    'Title: ' +
    eventBody.title +
    '\n' +
    'Rating: ' +
    eventBody.rating +
    '\n' +
    'Genres: ' +
    eventBody.genres;

  const sourceEmail = process.env.SOURCE_EMAIL || ''; // Ideally it needs to be validated and logged if not set
  const destinationEmail = process.env.DESTINATION_EMAIL || ''; // Ideally it needs to be validated and logged if not set

  const command = new SendEmailCommand({
    Source: sourceEmail,
    Destination: {
      ToAddresses: [destinationEmail],
    },
    Message: {
      Body: {
        Text: {
          Charset: 'UTF-8',
          Data: body,
        },
      },
      Subject: {
        Charset: 'UTF-8',
        Data: subject,
      },
    },
  });

  await client.send(command);
}
