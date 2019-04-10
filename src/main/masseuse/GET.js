const AWS = require('aws-sdk');
const logger = require("../logger.js")

module.exports = async (event) => {
  logger.debug('Masseuse GET Handler Invoked');

  const params = {
    Key: {
     "phone": {
       S: event.pathParameters.phone
      }
    },
    TableName: "kinesis-example-masseuse"
  };

  const dynamoDB = new AWS.DynamoDB();
  try {
    const data = await dynamoDB.getItem(params).promise();
    if (data && data.Item) {
      return {
        statusCode: 200,
        body: JSON.stringify({
          phone: data.Item.phone.S,
          name: data.Item.name.S,
          gender: data.Item.gender.S
        })
      };
    } else {
      return {
        statusCode: 404
      };
    }
   } catch(error) {
    return {
      statusCode: 500,
      body: JSON.stringify(error)
    };
   }
}
