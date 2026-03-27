module uim.sap.service.mixins.store;
import uim.sap.service;

mixin(ShowModule!());

@safe:
string sapStoreTemplate() {
  return q{
    this() {
      super();
    }

    this(Json initData) {
      super(initData);
    }

    this(Json[] initData) {
      super(initData);
    }

    this(Json[string] initData) {
      super(initData);
    }
  };
}

template SAPStoreTemplate(alias Symbol) {
  const char[] SAPStoreTemplate = sapStoreTemplate();
}
