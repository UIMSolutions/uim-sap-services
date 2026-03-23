module uim.sap.cpi.models.request;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

class CPIRequest : SAPObject {
  mixin(SAPObjectTemplate!CPIRequest);

  string path;
  string[string] query;
  Json payload = Json.emptyObject;
}
