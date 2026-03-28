module uim.sap.service.mixins.obj;

import uim.sap.service;

mixin(ShowModule!());

@safe:
string sapObjectTemplate() {
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

template SAPObjectTemplate(alias Symbol) {
  const char[] SAPObjectTemplate = sapObjectTemplate();
}

string sapTenantObjectTemplate() {
  return q{
    this() {
      super();
    }

    this(UUID tenantId) {
      super();
      this.tenantId = tenantId;
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

    this(UUID tenantId, Json[string] initData) {
      super(initData);
      this.tenantId = tenantId;
    }
  };
}

template SAPTenantObjectTemplate(alias Symbol) {
  const char[] SAPTenantObjectTemplate = sapTenantObjectTemplate();
}