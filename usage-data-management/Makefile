IMAGE ?= uimsolutions/uim-usage-data-management-service:latest
CONTAINER ?= uim-usage-data-management-service

.PHONY: build run stop podman-build podman-run podman-stop

build:
	dub build

run:
	dub run

stop:
	pkill -f uim-usage-data-management-service || true

podman-build:
	podman build -t $(IMAGE) .

podman-run:
	podman run --rm -it --name $(CONTAINER) -p 8109:8109 $(IMAGE)

podman-stop:
	podman stop $(CONTAINER) || true
