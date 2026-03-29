module uim.sap.service.mixins.obj;

import uim.sap.service;

mixin(ShowModule!());

@safe:
string SAPEntityTemplate() {
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

template SAPEntityTemplate(alias Symbol) {
  const char[] SAPEntityTemplate = SAPEntityTemplate();
}

string SAPTenantEntityTemplate() {
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

template SAPTenantEntityTemplate(alias Symbol) {
  const char[] SAPTenantEntityTemplate = SAPTenantEntityTemplate();
}