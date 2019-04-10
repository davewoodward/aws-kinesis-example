const AWS = require('aws-sdk');
const logger = require("../logger.js")

module.exports = async (event) => {
  logger.debug('Masseuse POST Handler Invoked');

  const body = JSON.parse(event.body);
  if (body && body.name && body.phone && body.gender && ['male', 'female'].includes(body.gender.toLowerCase())) {
    const params = {
      Item: {
       "name": {
         S: body.name
        },
       "phone": {
         S: body.phone
        },
       "gender": {
         S: body.gender
        }
      },
      TableName: "kinesis-example-masseuse",
      ConditionExpression: "phone <> :phoneVal",
      ExpressionAttributeValues: {
        ":phoneVal" : {"S": body.phone}
      }
     };

    const dynamoDB = new AWS.DynamoDB();
    try {
      await dynamoDB.putItem(params).promise();
      return {
        statusCode: 201
      };
    } catch(error) {
      return {
        statusCode: 500,
        body: JSON.stringify(error)
      };
    }
  } else {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'name, phone, and a gender value of "male" or "female" must be provided.'
      })
    };
  }
}
