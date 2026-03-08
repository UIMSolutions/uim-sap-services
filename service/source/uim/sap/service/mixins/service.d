module uim.sap.service.mixins.service;
import uim.sap.service;

mixin(ShowModule!());

@safe:
string sapServiceTemplate() {
  return "
  this() {
    super();
  }

  this(Json[string] initData) {
    super(initData);
  }
  ";
}

template SAPServiceTemplate(alias Symbol) {
  const char[] SAPServiceTemplate = sapServiceTemplate();
}