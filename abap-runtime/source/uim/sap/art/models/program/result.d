module uim.sap.art.models.program.result;

import uim.sap.art;

mixin(ShowModule!());

@safe:

class ARTProgramResult : SAPObject {
  mixin(SAPObjectTemplate!ARTProgramResult);

  bool success;
  string message;
  int statusCode = 200;
  Json data = Json.emptyObject;
  string program;
  SysTime timestamp;
  UUID correlationId;

  override Json toJson() {
    return super.toJson
      .set("success", success)
      .set("message", message)
      .set("statusCode", statusCode)
      .set("data", data)
      .set("program", program)
      .set("timestamp", timestamp.toISOExtString())
      .set("correlationId", correlationId);
  }
}
