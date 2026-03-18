IMAGE ?= uimsolutions/uim-service-manager-service:latest
CONTAINER ?= uim-service-manager-service

.PHONY: build run stop podman-build podman-run podman-stop

build:
	dub build

run:
	dub run

stop:
	pkill -f uim-service-manager-service || true

podman-build:
	podman build -t $(IMAGE) .

podman-run:
	podman run --rm -it --name $(CONTAINER) -p 8111:8111 $(IMAGE)

podman-stop:
	podman stop $(CONTAINER) || true
