PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

IMAGE_NAME ?= ghcr.io/uimsolutions/uim-sap-mob
IMAGE_TAG  ?= latest

.PHONY: build run test clean container-build container-run uml uml-check uml-png uml-svg uml-clean

build:
	cd .. && dub build --config=default -- mobile

run:
	cd .. && dub run -- mobile

test:
	cd .. && dub test -- mobile

clean:
	rm -rf build/

container-build:
	podman build -t $(IMAGE_NAME):$(IMAGE_TAG) .

container-run:
	podman run --rm -p 8089:8089 \
		-e MOB_HOST=0.0.0.0 \
		-e MOB_PORT=8089 \
		-e MOB_BASE_PATH=/api/mob \
		$(IMAGE_NAME):$(IMAGE_TAG)

container-push:
	podman push $(IMAGE_NAME):$(IMAGE_TAG)

k8s-apply:
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/secret.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

k8s-delete:
	kubectl delete -f k8s/service.yaml || true
	kubectl delete -f k8s/deployment.yaml || true
	kubectl delete -f k8s/secret.yaml || true
	kubectl delete -f k8s/configmap.yaml || true

uml-check:
	@if [ -z "$(UML_FILES)" ]; then \
		echo "No PlantUML files found in $(UML_DIR)"; \
		exit 1; \
	fi

uml: uml-png

uml-png: uml-check
	$(PLANTUML) $(UML_FILES)

uml-svg: uml-check
	$(PLANTUML) -tsvg $(UML_FILES)

uml-clean:
	rm -f $(UML_DIR)/*.png $(UML_DIR)/*.svg
