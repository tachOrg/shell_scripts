import { DynamoDBClient, PutItemCommand } from '@aws-sdk/client-dynamodb';

export const handler = function(event, context, callback) {
  console.log('Event data: ' + JSON.stringify(event));
  const requestItems = buildRequestItems(event.Records[0]);
  console.log('Request items: ' + JSON.stringify(requestItems))
  const itemInput = buildRequests(requestItems);
  console.log('Input to send at DynamoDB: ' + JSON.stringify(itemInput));
  
  const objectToInsert = {
    "Item": itemInput,
    "TableName": "CPU_Stats"
  }
  console.log('Final object to DynamoDB: ' + JSON.stringify(objectToInsert));
  insertIntoDB(objectToInsert);
};

/**
 * Converts object received, parse into JSON format object and return it
 * 
 * Parameters:
 * records - Object
*/
const buildRequestItems = (records) => {
  const json = Buffer.from(records.kinesis.data, 'base64').toString('ascii');
  const item = JSON.parse(json);
  return {
    PutRequest: {
      Item: item
    }
  }
};

/**
 * Build an item with the objective to insert into DB and return it
 * 
 * Parameters:
 * requestItem - Object
*/
const buildRequests = (requestItem) => {
  const item = requestItem.PutRequest.Item;
  const dynamoItem = {};

  for (const key in item) {
    dynamoItem[key] = { S: item[key] };
  }

  return dynamoItem;
};

const dynamoDBClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const dynamoDBName = process.env.TABLE_NAME;

const commandInput = {
  RequestItems: {
    [dynamoDBName] : [ 
      {
        "PutRequest": {
          "Item": {
            "Name": { "S": "Koethl" },
            "StatusTime": { "S": "2023-01-30 21:30:00.000" }
          }, 
          "TableName": [dynamoDBName]
        }
      }
    ]
  }
};
// const command = new BatchWriteItemCommand(commandInput);

/**
 * Insert object received into Dynamo DB
 * 
 * Parameters:
 * input - Object
*/
const insertIntoDB = async (input) => {
  try {
    const getted = `Input getted: ${JSON.stringify(input)}`;
    console.log(getted);
    const finalCommand = new PutItemCommand(input);
    await dynamoDBClient.send(finalCommand);
    console.log('Sent');
  } catch (error) { 
    console.log('Error: ' + error);
  }
};

// insertIntoDB();
