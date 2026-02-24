PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

.PHONY: uml uml-png uml-svg uml-clean

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
