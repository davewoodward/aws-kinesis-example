const logger = require("./logger.js")

const moduleMap = {
  eventDELETE: require('./event/DELETE.js'),
  eventGET: require('./event/GET.js'),
  eventPOST: require('./event/POST.js'),
  eventPUT: require('./event/PUT.js'),
  masseuseDELETE: require('./masseuse/DELETE.js'),
  masseuseGET: require('./masseuse/GET.js'),
  masseusePOST: require('./masseuse/POST.js'),
  masseusePUT: require('./masseuse/PUT.js')
}

exports.myHandler = async function(event) {
  const NOERROR = null;

  logger.debug(`EVENT: ${JSON.stringify(event)}`);

  const resourceName = event.resource.match(/^\/([a-zA-Z]*)\/?({[a-zA-Z]*})?/)[1];
  const lookup = `${resourceName}${event.httpMethod}`;
  logger.debug(`LOOKUP: ${lookup}`);
  const func = moduleMap[lookup];

  if (func) {
    logger.debug('Handler Found');
    return func(event);
  } else {
    logger.debug('No Handler Found');
    return {
      "body": JSON.stringify({
        "statusCode": 405
      }),
    };
  }
}
