module uim.sap.service.mixins.config;

string sapConfigTemplate() {
  return "
  this() {
    super();
  }

  this(Json[string] initData) {
    super(initData);
  }
  ";
}

template SAPConfigTemplate(alias Symbol) {
  const char[] SAPConfigTemplate = sapConfigTemplate();
}