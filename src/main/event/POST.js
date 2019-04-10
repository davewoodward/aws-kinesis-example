const AWS = require('aws-sdk');
const logger = require("../logger.js")

module.exports = (event) => {
  logger.debug('Event POST Handler Invoked');
  return {
    statusCode: 405
  }
}
