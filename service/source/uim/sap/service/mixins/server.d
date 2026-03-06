module uim.sap.service.mixins.server;

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