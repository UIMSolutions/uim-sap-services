IMAGE ?= uimsolutions/uim-data-retention-service:latest
CONTAINER ?= uim-data-retention-service

.PHONY: build run stop podman-build podman-run podman-stop

build:
	dub build

run:
	dub run

stop:
	pkill -f uim-data-retention-service || true

podman-build:
	podman build -t $(IMAGE) .

podman-run:
	podman run --rm -it --name $(CONTAINER) -p 8110:8110 $(IMAGE)

podman-stop:
	podman stop $(CONTAINER) || true
