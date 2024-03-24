# [willmcpherson2.com](http://willmcpherson2.com)

## Log in

```sh
gcloud auth login
gcloud config set project willmcpherson2
gcloud compute ssh --zone "australia-southeast2-a" "willmcpherson2" --project "willmcpherson2"
```

## Set up Nix on Google Compute Engine

```sh
./bin/setup.sh
```

## Set up keys for nix-copy-closure

```sh
./bin/keys.sh
```

## Deploy

```sh
./bin/deploy.sh
```
