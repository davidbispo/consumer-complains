# Consumer Complains API
A simple Sinatra API to store and search for customer complains. It
uses Elastic Cloud on production and a regular elastic & kibana setup via
docker-compose.

The API has no authentication thus far.
## How to run locally
```
docker-compose up
```
and wait for elasticsearch to be available. To get started with elastic, create your first complain. It will
create the index and persist your first complain
## Check server functionality
The root addresses should return confirmation of functionality
```
curl --location --request GET 'localhost:9292'
curl --location --request GET 'https://customer-complains.herokuapp.com'
```
It should return confirmation of the server working
## How to run the tests
```
docker-compose exec api bash # for entering the container bash
rspec spec # to run all tests
rspec <relative_path_to_file> # to run a specific test
```
Should return confirmation of the server working
## API documentation
The API documentation can be found at:
Local calls
```
https://www.getpostman.com/collections/025e0460a08a7462e795
```
Production calls
```
https://www.getpostman.com/collections/e68b8926d45aa5529d23
```
