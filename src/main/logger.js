const winston = require("winston");

module.exports = winston.createLogger({
  level: process.env.LOG_LEVEL ? process.env.LOG_LEVEL : 'info',
  levels: winston.config.npm.levels,
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new (winston.transports.Console)({'timestamp':true}),
  ],
  exitOnError: false,
  silent: false
});
