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


## Reproducing the case where NSQ Consumer forever dies

Make sure that the application can run + NSQ is installed. Run `hivemind` to have the NSQ cluster running.

We'll start the application with `mix run --no-halt` after we get toxiproxy listening on ports 14150 / 14161 for nsqd / nsqlookupd respectively. Toxiproxy will allow us to inject faults to try to reproduce issues we see on production.

---

Install toxiproxy locally (https://github.com/Shopify/toxiproxy?tab=readme-ov-file#1-installing-toxiproxy)

If installed via brew: `brew services start toxiproxy`

Populate toxiproxy config with our NSQ setup via:
```
curl -X POST http://localhost:8474/populate -d "$(cat toxiproxy.json)"
```

Use the toxiproxy CLI to manipulate toxics:

This example adds 5.5s latency to the nsqlookupd endpoint.
```
toxiproxy-cli toxic add -t latency -a latency=5500 nsqlookupd-4161
```

You should get the following message back from the CLI:
> Added downstream latency toxic 'latency_downstream' on proxy 'nsqlookupd-4161'

In the meantime, you should see the following error from the sample application:
```
10:27:24.445 [error] Error connecting to http://127.0.0.1:14161/lookup?topic=my-queue: %HTTPoison.Error{reason: :timeout, id: nil}

10:27:24.445 [info] Stopping connections [{"parent:#PID<0.353.0>:conn:127.0.0.1:4150", #PID<0.358.0>}]

10:27:24.427 [error] Task #PID<0.363.0> started from #PID<0.352.0> terminating
** (stop) exited in: GenServer.call(:nsq_consumer_f5859b7ec8074003b04b3800154ffdc6, :discover_nsqds, 5000)
    ** (EXIT) time out
    (elixir 1.15.7) lib/gen_server.ex:1074: GenServer.call/3
    (elixir_nsq 1.1.0) lib/nsq/consumer/connections.ex:27: NSQ.Consumer.Connections.discovery_loop/1
    (elixir 1.15.7) lib/task/supervised.ex:101: Task.Supervised.invoke_mfa/2
Function: #Function<0.86036140/0 in NSQ.Consumer.Supervisor.init/1>
```

To remove the toxic, run:
```
 toxiproxy-cli toxic r --toxicName latency_downstream nsqlookupd-4161
```

Observation: The consumer does not restart or come back up after it terminates.
