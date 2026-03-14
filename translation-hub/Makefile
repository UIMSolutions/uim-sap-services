APP=translation-hub
IMAGE?=translation-hub:local

.PHONY: run build test podman-build podman-run docker-build docker-run k8s-apply k8s-delete

run:
	dub run

build:
	dub build -b release

test:
	dub test

podman-build:
	podman build -t $(IMAGE) -f Containerfile .

podman-run:
	podman run --rm -p 8080:8080 -e PORT=8080 $(IMAGE)

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker run --rm -p 8080:8080 -e PORT=8080 $(IMAGE)

k8s-apply:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete -f k8s/
