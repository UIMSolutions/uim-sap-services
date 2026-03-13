IMAGE ?= uimsolutions/uim-alert-notification-service:latest
CONTAINER ?= uim-alert-notification-service

.PHONY: build run stop podman-build podman-run podman-stop

build:
	dub build

run:
	dub run

stop:
	pkill -f uim-alert-notification-service || true

podman-build:
	podman build -t $(IMAGE) .

podman-run:
	podman run --rm -it --name $(CONTAINER) -p 8097:8097 $(IMAGE)

podman-stop:
	podman stop $(CONTAINER) || true
