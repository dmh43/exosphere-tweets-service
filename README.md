# Tweets Service [![Circle CI](https://circleci.com/gh/Originate/exosphere-tweets-service.svg?style=shield&circle-token=b8da91b53c5b269eeb2460e344f521461ffe9895)](https://circleci.com/gh/Originate/exosphere-tweets-service)
> An Exosphere service for storing tweets of data, which are associated to something

* tweets have
  * an owner (string)
    - referenced via the attribute `owner_id`
  * content (text)


## Installation

* install MongoDB

  ```
  brew install mongodb
  ```

* install dependencies

  ```
  bin/setup
  ```


## running

* start MongoDB

 ```
 mongod --config /usr/local/etc/mongod.conf
 ```

* start the service

  ```
  env SERVICE_NAME=tweets EXOCOMM_PORT=xxx EXORELAY_PORT=yyy exo-js
  ```


## Development

See your [developer documentation](CONTRIBUTING.md)
