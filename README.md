# [willmcpherson2.com](http://willmcpherson2.com)

## Build

```sh
nix-build
docker load < result
```

## Run

```sh
docker run -it -p 8000:80 -p 8001-8002:8001-8002 asia-east1-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
```

## Deploy

```sh
docker push asia-east1-docker.pkg.dev/willmcpherson2/willmcpherson2/willmcpherson2:latest
gcloud compute instances update-container willmcpherson2
```
