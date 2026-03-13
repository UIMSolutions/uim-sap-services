IMAGE ?= uimsolutions/uim-prm-service:latest
CONTAINER ?= uim-prm-service

.PHONY: build run stop podman-build podman-run podman-stop

build:
	dub build

run:
	dub run

stop:
	pkill -f uim-prm-service || true

podman-build:
	podman build -t $(IMAGE) .

podman-run:
	podman run --rm -it --name $(CONTAINER) -p 8096:8096 $(IMAGE)

podman-stop:
	podman stop $(CONTAINER) || true
