module uim.sap.service.helpers.network;

import uim.sap.service;

mixin(ShowModule!());

@safe:

/**
  * Helper to send error responses in a consistent format.
  *
  * @param res The HTTP response object to write to
  * @param message A human-readable error message
  * @param statusCode The HTTP status code to use (e.g. 400, 404, 500)
  */
void respondError(HTTPServerResponse res, string message, int statusCode) {
  Json payload = Json.emptyObject
    .set("success", false)
    .set("message", message)
    .set("statusCode", statusCode);

  res.writeJsonBody(payload, statusCode);
}
