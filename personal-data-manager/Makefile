PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

IMAGE_NAME ?= ghcr.io/uimsolutions/uim-sap-pdm
IMAGE_TAG  ?= latest

.PHONY: build run test clean container-build container-run uml uml-check uml-png uml-svg uml-clean

build:
	cd .. && dub build --config=default -- personal-data-manager

run:
	cd .. && dub run -- personal-data-manager

test:
	cd .. && dub test -- personal-data-manager

clean:
	rm -rf build/

container-build:
	podman build -t $(IMAGE_NAME):$(IMAGE_TAG) .

container-run:
	podman run --rm -p 8092:8092 \
		-e PDM_HOST=0.0.0.0 \
		-e PDM_PORT=8092 \
		-e PDM_BASE_PATH=/api/pdm \
		-e PDM_MULTITENANCY=true \
		$(IMAGE_NAME):$(IMAGE_TAG)
