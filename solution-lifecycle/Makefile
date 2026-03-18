.PHONY: build run test clean docker podman

SERVICE_NAME := uim-slm-service
IMAGE_TAG    := uim-sap-slm:local

build:
	dub build --root=.

run: build
	./build/$(SERVICE_NAME)

test:
	dub test --root=.

clean:
	rm -rf build/.$(SERVICE_NAME) build/$(SERVICE_NAME)

docker:
	docker build -t $(IMAGE_TAG) .

podman:
	podman build -t $(IMAGE_TAG) .

docker-run: docker
	docker run --rm -p 8120:8120 $(IMAGE_TAG)

podman-run: podman
	podman run --rm -p 8120:8120 $(IMAGE_TAG)
