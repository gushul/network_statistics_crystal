# Network Statistics Microservice

This is a microservice built with the Crystal language that collects network statistics over a target provided.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have Crystal language installed on your machine.

```bash
# For macOS
brew install crystal
```

### Installing
Clone the repository

```bash
git clone https://github.com/yourusername/network-statistics-microservice.git
```

Navigate into the project directory

```bash
cd network-statistics-microservice
```

Install the project dependencies

```bash
shards install
```

#### Usage
Build the application

```bash
make build
```

##### Run the server

```bash
make run
```

The server will start listening on http://localhost:8080.

#### Running the tests
To run the tests, you can use the following command:

```bash
make test
```

The microservice will listen on http://localhost:8080.

Send a POST request to http://localhost:8080 with the JSON input data. The microservice will process the data and return the collected network statistics as a JSON response.

Example JSON input:

```json
{
  "endpoints": [
    {
      "method": "POST",
      "url": "http://example.com/info",
      "headers": [
        {
          "name": "Cookie",
          "value": "token=DEADCAFE"
        }
      ],
      "body": "hello"
    }
  ],
  "num_requests": 5,
  "retry_failed": false
}
```

Example JSON response:

```json
{
  "endpoints": [
    {
      "min": 10,
      "max": 20,
      "avg": 12,
      "fails": 1
    }
  ],
  "summary": {
    "min": 10,
    "max": 20,
    "avg": 12,
    "fails": 1
  }
}
```


