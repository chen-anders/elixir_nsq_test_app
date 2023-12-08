#!/bin/bash -e

curl -X POST "localhost:4151/topic/create?topic=my-queue"
curl -X POST "localhost:4151/channel/create?topic=my-queue&channel=my-channel"
