# Consumer Complains API
A simple Sinatra API to store and search for customer complains. It
uses Elastic Cloud on production and regular elastic & kibana setup via
docker-compose.
## How to run locally
```
docker-compose up
```
and wait for elasticsearch to be available

```
GET http://localhost:9292
```
Should return confirmation of the server working

## How to run the tests
```
docker-compose exec api bash # for entering the container bash
rspec spec # to run all tests
rspec <relative_path_to_file> # to run a specific test
```

## How to run the api on heroku
```
GET https://customer-complains.herokuapp.com
```
Should return confirmation of the server working

## API documentation

