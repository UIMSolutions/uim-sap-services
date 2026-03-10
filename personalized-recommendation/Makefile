PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

IMAGE_NAME ?= ghcr.io/uimsolutions/uim-sap-pre
IMAGE_TAG  ?= latest

.PHONY: build run test clean container-build container-run uml uml-check uml-png uml-svg uml-clean

build:
	cd .. && dub build --config=default -- personalized-recommendation

run:
	cd .. && dub run -- personalized-recommendation

test:
	cd .. && dub test -- personalized-recommendation

clean:
	rm -rf build/

container-build:
	podman build -t $(IMAGE_NAME):$(IMAGE_TAG) .

container-run:
	podman run --rm -p 8093:8093 \
		-e PRE_HOST=0.0.0.0 \
		-e PRE_PORT=8093 \
		-e PRE_BASE_PATH=/api/pre \
		-e PRE_MULTITENANCY=true \
		$(IMAGE_NAME):$(IMAGE_TAG)
