module uim.sap.service.mixins.server;
import uim.sap.service;

mixin(ShowModule!());

@safe:
string sapServerTemplate() {
  return "
  this() {
    super();
  }

  this(Json[string] initData) {
    super(initData);
  }
  ";
}

template SAPServerTemplate(alias Symbol) {
  const char[] SAPServerTemplate = sapServerTemplate();
}