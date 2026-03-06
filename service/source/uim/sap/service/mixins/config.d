module uim.sap.service.mixins.config;

string sapConfigTemplate() {
  return "
  this() {
    super();
  };
  ";
}

template SAPConfigTemplate(alias Symbol) {
  const char[] SAPConfigTemplate = sapConfigTemplate();
}