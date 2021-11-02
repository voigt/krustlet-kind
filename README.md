# Krustlet in Docker

This is a (hacky) proof of concept to spawn a krustlet within [KIND](https://kind.sigs.k8s.io/).

## How to use

Build Krustlet Node Image:

```bash
docker build --no-cache . -t kindest/node:1.21.1-krustlet-v1.0.0-alpha.1
```

Create Cluster:

```bash
kind create cluster --config=examples/kind.yaml --name=kruste
```

Test

```bash
kubectl apply -f examples/test_workload_1.yaml
```

## Hack

Get first worker

```bash
docker exec -it $(docker ps --format "{{.ID}}" -f name="worker2" | tail -n1) /bin/bash
```

Start image without kind
```
$ docker run -it -d \
    --entrypoint='/bin/bash' \
    kindest/node:1.21.1-krustlet-v1.0.0-alpha.1