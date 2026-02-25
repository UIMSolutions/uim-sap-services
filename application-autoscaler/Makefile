PLANTUML ?= plantuml
UML_DIR ?= docs/uml
UML_FILES := $(wildcard $(UML_DIR)/*.puml)

.PHONY: uml uml-png uml-svg uml-clean

uml: uml-png

uml-png:
	$(PLANTUML) $(UML_FILES)

uml-svg:
	$(PLANTUML) -tsvg $(UML_FILES)

uml-clean:
	rm -f $(UML_DIR)/*.png $(UML_DIR)/*.svg
