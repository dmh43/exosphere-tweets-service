# Tweets Service [![Circle CI](https://circleci.com/gh/Originate/exosphere-tweets-service.svg?style=shield&circle-token=b571517a2b36b03bd440ad7056d2a072c463dc63)](https://circleci.com/gh/Originate/exosphere-tweets-service)
> An Exosphere service for storing entry data


## Installation

* install MongoDB

  ```
  brew install mongodb
  ```

* install dependencies

  ```
  npm install
  ```


## running

* start MongoDB

  ```
  mongod --config /usr/local/etc/mongod.conf
  ```

* start the service

  ```
  env EXOCOMM_PORT=4000 EXORELAY_PORT=4001 bin/start
  ```


## Development

See your [developer documentation](CONTRIBUTING.md)
