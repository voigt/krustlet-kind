# Krustlet in Docker

## How to use

```bash
kind create cluster --config=kind.yaml --name=kruste
```


## Handling

get first worker

```bash
docker exec -it $(docker ps --format "{{.ID}}" -f name="worker2" | tail -n1) /bin/bash
```

Start image without kind
```
$ docker run -it -d \
    --entrypoint='/bin/bash' \
    kindest/node:1.21.1-krustlet-v1.0.0-alpha.1-systemd