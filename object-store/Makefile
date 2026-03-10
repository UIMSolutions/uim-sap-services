PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

IMAGE_NAME ?= ghcr.io/uimsolutions/uim-sap-obs
IMAGE_TAG  ?= latest

.PHONY: build run test clean container-build container-run uml uml-check uml-png uml-svg uml-clean

build:
	cd .. && dub build --config=default -- object-store

run:
	cd .. && dub run -- object-store

test:
	cd .. && dub test -- object-store

clean:
	rm -rf build/

container-build:
	podman build -t $(IMAGE_NAME):$(IMAGE_TAG) .

container-run:
	podman run --rm -p 8091:8091 \
		-e OBS_HOST=0.0.0.0 \
		-e OBS_PORT=8091 \
		-e OBS_BASE_PATH=/api/obs \
		-e OBS_DEFAULT_PROVIDER=aws \
		-e OBS_DEFAULT_REGION=eu-central-1 \
		$(IMAGE_NAME):$(IMAGE_TAG)
