module uim.sap.service.helpers.network;

import uim.sap.service;

mixin(ShowModule!());

@safe:

void respondError(HTTPServerResponse res, string message, int statusCode) {
  Json payload = Json.emptyObject
    .set("success", false)
    .set("message", message)
    .set("statusCode", statusCode);

  res.writeJsonBody(payload, statusCode);
}
