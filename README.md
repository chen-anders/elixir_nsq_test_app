# Test Elixir App with elixir_nsq

## Pre-requisites

- NSQ 1.2+ should be installed
- `foreman` or `hivemind` to run the Procfile

## Setting up NSQ

Once the NSQ cluster is running (with `foreman`), run `./setup_nsq.sh` to bootstrap the cluster with a topic and channel (topic: `my-queue`, channel: `my-channel`).

## Running the application

`mix run --no-halt`

App runs on port 4040 with the following routes:

- GET `/healthz` - returns 200 OK
- POST `/ingest` - takes a JSON body in the format of `{"msg": "hello world"}` and parses the JSON - writes the contents of `msg` into the topic `my-queue` in NSQ

The application also starts up an NSQ consumer that reads off of the `my-channel` channel of the `my-queue` topic.

Running the following should get us "hello world" and "message processed" in the server logs.

```
> curl -X POST -H "Content-Type: application/json" localhost:4040/ingest -d '{"msg": "hello world"}'
Message ingested successfully%
```
